#!/bin/bash
# EC2 Storage Expansion Helper Script
# This script helps expand EBS volume and filesystem on EC2 instances

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check current disk usage
check_disk_usage() {
    print_status "Current disk usage:"
    df -h
    echo
    print_status "Block device information:"
    lsblk
    echo
}

# Function to find large files and directories
find_large_files() {
    print_status "Finding large files and directories..."
    echo
    echo "Top 10 largest directories:"
    du -h / 2>/dev/null | sort -rh | head -10
    echo
    echo "Files larger than 100MB:"
    find / -type f -size +100M 2>/dev/null | head -10 | xargs -I {} ls -lh {} 2>/dev/null
    echo
}

# Function to clean up disk space
cleanup_disk() {
    print_warning "Cleaning up disk space..."
    
    # Clean package manager cache
    if command -v yum &> /dev/null; then
        sudo yum clean all
    elif command -v apt-get &> /dev/null; then
        sudo apt-get clean
        sudo apt-get autoremove -y
    fi
    
    # Clean log files older than 30 days
    if [ -d /var/log ]; then
        sudo find /var/log -type f -name "*.log" -mtime +30 -delete 2>/dev/null || true
    fi
    
    # Clean Docker if installed
    if command -v docker &> /dev/null; then
        print_status "Cleaning Docker resources..."
        docker system prune -af --volumes || true
    fi
    
    # Clean tmp directory
    sudo rm -rf /tmp/* 2>/dev/null || true
    
    print_status "Cleanup completed. New disk usage:"
    df -h
}

# Function to expand filesystem
expand_filesystem() {
    local device=$1
    local partition=$2
    
    print_status "Expanding filesystem on ${device}${partition}..."
    
    # Check if growpart is installed
    if ! command -v growpart &> /dev/null; then
        print_status "Installing growpart..."
        if command -v yum &> /dev/null; then
            sudo yum install -y cloud-utils-growpart
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y cloud-guest-utils
        fi
    fi
    
    # Expand partition
    print_status "Expanding partition..."
    sudo growpart $device $partition || {
        print_error "Failed to expand partition. It might already be at maximum size."
    }
    
    # Determine filesystem type
    fs_type=$(df -T / | awk 'NR==2 {print $2}')
    print_status "Detected filesystem type: $fs_type"
    
    # Expand filesystem based on type
    case $fs_type in
        xfs)
            print_status "Expanding XFS filesystem..."
            sudo xfs_growfs /
            ;;
        ext4|ext3|ext2)
            print_status "Expanding EXT filesystem..."
            sudo resize2fs ${device}${partition}
            ;;
        *)
            print_error "Unsupported filesystem type: $fs_type"
            exit 1
            ;;
    esac
    
    print_status "Filesystem expansion completed!"
}

# Main menu
show_menu() {
    echo
    echo "===== EC2 Storage Management ====="
    echo "1. Check current disk usage"
    echo "2. Find large files and directories"
    echo "3. Clean up disk space"
    echo "4. Expand filesystem (after EBS volume expansion)"
    echo "5. Full expansion process guide"
    echo "6. Exit"
    echo
}

# Full expansion guide
show_expansion_guide() {
    cat << EOF

${GREEN}=== Complete EBS Volume Expansion Guide ===${NC}

${YELLOW}Step 1: Expand EBS Volume in AWS Console${NC}
1. Go to EC2 Console > Volumes
2. Select your volume and click "Actions" > "Modify Volume"
3. Enter new size and click "Modify"
4. Wait for status to change to "in-use" (5-10 minutes)

${YELLOW}Step 2: Run this script option 4${NC}
After AWS console changes are complete, run this script and select option 4

${YELLOW}Step 3: Verify${NC}
Check new disk size with 'df -h'

Press Enter to continue...
EOF
    read
}

# Interactive mode
if [ $# -eq 0 ]; then
    while true; do
        show_menu
        read -p "Select an option (1-6): " choice
        
        case $choice in
            1)
                check_disk_usage
                ;;
            2)
                find_large_files
                ;;
            3)
                cleanup_disk
                ;;
            4)
                # Auto-detect root device
                root_device=$(df / | awk 'NR==2 {print $1}' | sed 's/[0-9]*$//')
                partition_num=$(df / | awk 'NR==2 {print $1}' | grep -o '[0-9]*$')
                
                print_status "Detected root device: $root_device"
                print_status "Detected partition: $partition_num"
                
                read -p "Proceed with filesystem expansion? (y/n): " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    expand_filesystem "$root_device" "$partition_num"
                    check_disk_usage
                fi
                ;;
            5)
                show_expansion_guide
                ;;
            6)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
else
    # Command line mode
    case $1 in
        check)
            check_disk_usage
            ;;
        cleanup)
            cleanup_disk
            ;;
        expand)
            if [ -z "$2" ] || [ -z "$3" ]; then
                print_error "Usage: $0 expand <device> <partition_number>"
                print_error "Example: $0 expand /dev/xvda 1"
                exit 1
            fi
            expand_filesystem "$2" "$3"
            ;;
        *)
            echo "Usage: $0 [check|cleanup|expand <device> <partition>]"
            echo "Or run without arguments for interactive mode"
            exit 1
            ;;
    esac
fi