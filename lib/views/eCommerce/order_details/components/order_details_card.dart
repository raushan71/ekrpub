import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
// import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/order/order_details_model.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

class OrderDetailsCard extends ConsumerStatefulWidget {
  final OrderDetails orderDetails;
  const OrderDetailsCard({
    super.key,
    required this.orderDetails,
  });

  @override
  ConsumerState<OrderDetailsCard> createState() => _OrderDetailsCardState();
}

class _OrderDetailsCardState extends ConsumerState<OrderDetailsCard> {
  static final isFileExists = StateProvider<bool>((ref) => false);
  static final isPaymentReceiptFileExists = StateProvider<bool>((ref) => false);
  static final isloading = StateProvider<bool>((ref) => false);
  static final isDownloadPaymentReceiptloading =
      StateProvider<bool>((ref) => false);
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _init();
    _portListener();
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  Future<void> _init() async {
    ref.read(isFileExists.notifier).state =
        await _checkFileExists(isDownloadInvoice: true) != null;

    ref.read(isPaymentReceiptFileExists.notifier).state =
        await _checkFileExists(isDownloadInvoice: false) != null;
  }

  _portListener() {
    print("Port listener triggered");
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      print("Download callback triggered");
      String taskId = data[0];
      int status = data[1];
      int process = data[2];

      if (status == DownloadTaskStatus.complete.index) {
        // Print message when download is complete
        print("File22 is downloaded");
        final isInvoice = taskId.contains('invoice'); // Identify file type
        final fileExists = await _checkFileExists(isDownloadInvoice: isInvoice);

        if (isInvoice) {
          ref.read(isFileExists.notifier).state = fileExists != null;
          ref.read(isloading.notifier).state = false; // Reset loading state
        } else {
          ref.read(isPaymentReceiptFileExists.notifier).state =
              fileExists != null;
          ref.read(isDownloadPaymentReceiptloading.notifier).state =
              false; // Reset loading state
        }

        GlobalFunction.showCustomSnackbar(
            message: 'Download Complete!', isSuccess: true);
      } else if (status == DownloadTaskStatus.failed.index) {
        // Reset loading states on failure
        ref.read(isloading.notifier).state = false;
        ref.read(isDownloadPaymentReceiptloading.notifier).state = false;

        GlobalFunction.showCustomSnackbar(
            message: 'Download Failed!', isSuccess: false);
      }

      if (process == 100 || status == DownloadTaskStatus.failed.index) {
        // Ensure loading state is reset for both invoice and receipt
        if (taskId.contains('invoice')) {
          ref.read(isloading.notifier).state = false;
        } else {
          ref.read(isDownloadPaymentReceiptloading.notifier).state = false;
        }
      }
    });
  }

  Future<String?> _checkFileExists({required bool isDownloadInvoice}) async {
    final saveDir = await _getDownloadDirectory();
    final fileName = isDownloadInvoice
        ? 'invoice-${widget.orderDetails.data.order.orderCode}.pdf'
        : 'payment-receipt-${widget.orderDetails.data.order.orderCode}.pdf';
    final filePath = '$saveDir/$fileName';
    final file = File(filePath);

    return await file.exists() ? filePath : null;
  }

  Future<String?> _getDownloadDirectory() async {
    Directory? appDocDir;

    if (Platform.isAndroid) {
      appDocDir = Directory('/storage/emulated/0/Download');
      if (!await appDocDir.exists()) {
        appDocDir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    return appDocDir?.path;
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
  }

  Future<void> _downloadFile({required bool isDownloadInvoice}) async {
    await _requestPermission();
    final url = isDownloadInvoice
        ? widget.orderDetails.data.order.invoiceUrl ?? ''
        : '${widget.orderDetails.data.order.paymentReceiptUrl}';
    final saveDir = await _getDownloadDirectory();
    final fileName = isDownloadInvoice
        ? 'invoice-${widget.orderDetails.data.order.orderCode}.pdf'
        : 'payment-receipt-${widget.orderDetails.data.order.orderCode}.pdf';
    final filePath =
        await _checkFileExists(isDownloadInvoice: isDownloadInvoice);

    if (filePath == null) {
      isDownloadInvoice
          ? ref.read(isloading.notifier).state = true
          : ref.read(isDownloadPaymentReceiptloading.notifier).state = true;
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: saveDir!,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      if (taskId != null) {
        if (isDownloadInvoice) {
          ref.read(isloading.notifier).state = false;
          ref.read(isFileExists.notifier).state = true;
        } else {
          ref.read(isPaymentReceiptFileExists.notifier).state = true;
          ref.read(isDownloadPaymentReceiptloading.notifier).state = false;
        }

        // GlobalFunction.showCustomSnackbar(
        //     message: 'Download Complete!', isSuccess: true);
      }
    } else {
      OpenFile.open(filePath);
    }
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlobalFunction.getContainerColor(),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildRowWidget(
            context: context,
            key: S.of(context).orderStatus,
            value: widget.orderDetails.data.order.orderStatus,
            isOrderStatus: true,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).orderId,
            value: widget.orderDetails.data.order.orderCode,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).orderDate,
            value: DateFormat('d MMMM y', 'en_US').format(
                DateTime.parse(widget.orderDetails.data.order.createdAt)),
          ),
          Gap(14.h),
          _buildPaymentMethodRow(),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).vatTax,
            value: GlobalFunction.price(
              ref: ref,
              price: widget.orderDetails.data.order.taxAmount.toString(),
            ),
            isAmount: false,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).deliveryCharge,
            value: GlobalFunction.price(
              ref: ref,
              price: widget.orderDetails.data.order.deliveryCharge.toString(),
            ),
            isAmount: false,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).totalAmount,
            value: GlobalFunction.price(
              ref: ref,
              price: widget.orderDetails.data.order.payableAmount.toString(),
            ),
            isAmount: false,
          ),
          Gap(14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ref.watch(isDownloadPaymentReceiptloading)
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () => _downloadFile(isDownloadInvoice: false),
                      child: Row(
                        children: [
                          Icon(
                            ref.watch(isPaymentReceiptFileExists)
                                ? Icons.open_in_new
                                : Icons.cloud_download,
                            color: EcommerceAppColor.gray,
                            size: 18.sp,
                          ),
                          Gap(5.w),
                          Text(
                            ref.watch(isPaymentReceiptFileExists)
                                ? 'Open Payment Slip'
                                : S.of(context).downloadPaymentSlip,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                fontSize: 12.sp,
                                color: colors(context).primaryColor),
                          )
                        ],
                      ),
                    ),
              ref.watch(isloading)
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () => _downloadFile(isDownloadInvoice: true),
                      child: Row(
                        children: [
                          Icon(
                            ref.watch(isFileExists)
                                ? Icons.open_in_new
                                : Icons.cloud_download,
                            color: EcommerceAppColor.gray,
                            size: 18.sp,
                          ),
                          Gap(5.w),
                          Text(
                            ref.watch(isFileExists)
                                ? 'Open Invoice '
                                : S.of(context).downloadInvoice,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                fontSize: 12.sp,
                                color: colors(context).primaryColor),
                          )
                        ],
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRowWidget({
    required BuildContext context,
    required String key,
    required dynamic value,
    bool isAmount = false,
    bool isOrderStatus = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: AppTextStyle(context).bodyTextSmall,
        ),
        if (isOrderStatus) ...[
          GlobalFunction.getStatusWidget(context: context, status: value)
        ] else ...[
          Consumer(builder: (context, ref, _) {
            return Text(
              isAmount
                  ? '${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}$value'
                  : value.toString(),
              style: AppTextStyle(context).bodyText,
            );
          }),
        ]
      ],
    );
  }

  Widget _buildPaymentMethodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(ContextLess.context).paymentMethod,
          style: AppTextStyle(ContextLess.context).bodyTextSmall,
        ),
        if (widget.orderDetails.data.order.paymentMethod == 'Cash Payment') ...[
          Text(
            widget.orderDetails.data.order.paymentMethod,
            style: AppTextStyle(ContextLess.context).bodyText,
          ),
        ] else
          Row(
            children: [
              Text(
                widget.orderDetails.data.order.paymentMethod,
                style: AppTextStyle(ContextLess.context).bodyText,
              ),
              Gap(4.w),
              _buildPaymentStatusWidget(),
            ],
          ),
      ],
    );
  }

  Widget _buildPaymentStatusWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: widget.orderDetails.data.order.paymentStatus == 'Pending'
            ? EcommerceAppColor.carrotOrange
            : EcommerceAppColor.green,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: Text(
          widget.orderDetails.data.order.paymentStatus.toUpperCase()[0] +
              widget.orderDetails.data.order.paymentStatus.substring(1),
          style: AppTextStyle(ContextLess.context)
              .bodyText
              .copyWith(fontSize: 12.sp, color: EcommerceAppColor.white),
        ),
      ),
    );
  }

  @pragma("vm:entry-point")
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
}
