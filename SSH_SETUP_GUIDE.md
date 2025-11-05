# SSH Setup Guide for GitHub

## Step 1: Generate SSH Key

Run this command in PowerShell (replace `your_email@example.com` with your GitHub email):

```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**When prompted:**
- Press Enter to accept the default file location (`C:\Users\YourName\.ssh\id_ed25519`)
- Optionally set a passphrase for extra security (or press Enter for no passphrase)

## Step 2: Start SSH Agent

```powershell
# Start the ssh-agent service
Start-Service ssh-agent

# Or if using Git Bash:
eval "$(ssh-agent -s)"
```

## Step 3: Add SSH Key to SSH Agent

```powershell
ssh-add ~\.ssh\id_ed25519
```

## Step 4: Copy Your Public Key

```powershell
cat ~\.ssh\id_ed25519.pub
```

**Copy the entire output** (starts with `ssh-ed25519` and ends with your email)

## Step 5: Add SSH Key to GitHub

1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Give it a title (e.g., "Windows PC" or "Development Machine")
4. Paste your public key in the "Key" field
5. Click "Add SSH key"

## Step 6: Test SSH Connection

```powershell
ssh -T git@github.com
```

You should see: `Hi raushan71! You've successfully authenticated...`

## Step 7: Switch Git Remote to SSH (Optional)

If you want to use SSH instead of HTTPS:

```powershell
git remote set-url origin git@github.com:raushan71/ekrpub.git
```

Verify:
```powershell
git remote -v
```

## Troubleshooting

### If SSH Agent is not running:
```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
```

### If you get "Permission denied":
- Make sure you added the public key (`.pub` file) to GitHub, not the private key
- Check that the email in your SSH key matches your GitHub account

### For existing HTTPS setup:
You can keep using HTTPS if you prefer. SSH is optional but recommended for better security.

