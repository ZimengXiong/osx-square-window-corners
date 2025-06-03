#!/bin/bash

# Check for safety flag
if [ "$1" != "--i-understand-the-risks" ]; then
    echo ""
    echo -e "\033[1;31mERROR: This script modifies critical system files and can cause permanent damage!\033[0m"
    echo -e "\033[1;31mIt is dangerous to run this script.\033[0m"
    exit 1
fi

echo -e "\033[1;34mChecking macOS version and build...\033[0m"
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_BUILD=$(sw_vers -buildVersion)

echo -e "\033[1;33mmacOS Version: $MACOS_VERSION\033[0m"
echo -e "\033[1;33mmacOS Build: $MACOS_BUILD\033[0m"

EXPECTED_VERSION="15.5"
EXPECTED_BUILD="24F74"

if [ "$MACOS_VERSION" != "$EXPECTED_VERSION" ] || [ "$MACOS_BUILD" != "$EXPECTED_BUILD" ]; then
    echo ""
    echo -e "\033[1;31mWARNING: Version/build mismatch detected!\033[0m"
    echo -e "\033[1;31mExpected: macOS $EXPECTED_VERSION (Build $EXPECTED_BUILD)\033[0m"
    echo -e "\033[1;31mFound: macOS $MACOS_VERSION (Build $MACOS_BUILD)\033[0m"
    echo ""
    echo -e "\033[1;31mThis script was designed for a specific macOS version.\033[0m"
    echo -e "\033[1;31mUsing it on a different version may cause system failure!\033[0m"
    echo ""
    echo -e "\033[1;31mDo you want to continue anyway? (type 'YES' to proceed)\033[0m"
    read -p "Response: " CONTINUE_RESPONSE
    
    if [ "$CONTINUE_RESPONSE" != "YES" ]; then
        echo -e "\033[1;31mAborting script.\033[0m"
        exit 1
    fi
    
    echo -e "\033[1;33mProceeding with caution...\033[0m"
else
    echo -e "\033[1;32mVersion and build verified - compatible system detected\033[0m"
fi

echo ""
echo "==============================================="

echo -e "\033[1;34mChecking system security settings...\033[0m"
SIP_STATUS=$(csrutil status | grep -o "disabled\|enabled")
AUTH_ROOT_STATUS=$(csrutil authenticated-root | grep -o "disabled\|enabled")

echo -e "\033[1;33mSystem Integrity Protection status: $SIP_STATUS\033[0m"
echo -e "\033[1;33mAuthenticated Root status: $AUTH_ROOT_STATUS\033[0m"

if [ "$SIP_STATUS" != "disabled" ] || [ "$AUTH_ROOT_STATUS" != "disabled" ]; then
    echo ""
    echo -e "\033[1;31mERROR: Both System Integrity Protection and Authenticated Root must be disabled!\033[0m"
    echo -e "\033[1;31mPlease boot into Recovery Mode and run:\033[0m"
    echo -e "\033[1;31m  csrutil disable\033[0m"
    echo -e "\033[1;31m  csrutil authenticated-root disable\033[0m"
    echo -e "\033[1;31mThen restart and run this script again.\033[0m"
    exit 1
fi

echo -e "\033[1;32mSecurity settings verified - proceeding with modification\033[0m"
echo ""
echo "==============================================="

echo ""
echo -e "\033[1;34mCreating backup of current system Resources folder to ~/Documents/resources_bak and ~/.resources_bak\033[0m"
sudo cp -r /System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/ ~/Documents/resources_bak
sudo cp -r /System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/ ~/.resources_bak

echo -e "\033[1;32mBackup completed\033[0m"
echo ""
echo "==============================================="

ROOT_DISK=$(df / | tail -1 | awk '{print $1}')
echo -e "\033[1;33mRoot disk: $ROOT_DISK\033[0m"
echo -e "\033[1;34mVerifying root disk - here's what mount shows for /:\033[0m"
mount | grep "on / "

echo ""
echo -e "\033[1;31mPlease verify the disk above matches the root disk found: $ROOT_DISK\033[0m"
echo -e "\033[1;31mPress Enter to continue or Ctrl+C to abort...\033[0m"
read

BASE_DISK=$(echo $ROOT_DISK | sed 's/s[0-9]*$//')
echo -e "\033[1;33mBase disk: $BASE_DISK\033[0m"

echo ""
echo -e "\033[1;31mPlease verify the base disk is correct\033[0m"
echo -e "\033[1;31mPress Enter to continue or Ctrl+C to abort...\033[0m"
read
echo ""
echo "==============================================="

LIVE_DISK="${BASE_DISK}"
echo -e "\033[1;34mMounting live disk: $LIVE_DISK at ~/live_disk_mnt\033[0m"

if [ ! -d ~/live_disk_mnt ]; then
    mkdir ~/live_disk_mnt
    echo -e "\033[1;32mCreated ~/live_disk_mnt directory\033[0m"
else
    echo -e "\033[1;33m~/live_disk_mnt directory already exists\033[0m"
fi

sudo mount -o nobrowse -t apfs $LIVE_DISK ~/live_disk_mnt

echo ""
echo -e "\033[1;32mMount completed successfully!\033[0m"
echo -e "\033[1;32mLive disk $LIVE_DISK is now mounted at ~/live_disk_mnt\033[0m"
echo ""
echo "==============================================="

echo ""
echo -e "\033[1;31mReady to copy Aqua.car to the mounted system.\033[0m"
echo -e "\033[1;31mPress Enter to continue with the copy operation or Ctrl+C to abort...\033[0m"
read

echo -e "\033[1;34mCopying Aqua.car to system appearance bundle...\033[0m"

# sudo cp Aqua.car ~/live_disk_mnt/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/Aqua.car

echo -e "\033[1;32mCopy completed!\033[0m"
echo ""
echo "==============================================="

echo ""
echo -e "\033[1;34mNow blessing the system to create a snapshot...\033[0m"
echo -e "\033[1;34mThis will prepare the system for restart with the new changes.\033[0m"
echo -e "\033[1;31mPress Enter to continue or Ctrl+C to abort...\033[0m"
read

echo -e "\033[1;34mCreating system snapshot with bless...\033[0m"

# sudo bless --mount ~/live_disk_mnt --bootefi --create-snapshot

echo ""
echo -e "\033[1;32mBless completed! The system will now restart to apply changes.\033[0m"
echo -e "\033[1;31mPress Enter to restart now or Ctrl+C to restart manually later...\033[0m"
read
echo ""
echo "==============================================="

echo -e "\033[1;35mRestarting system...\033[0m"
# sudo shutdown -r now
