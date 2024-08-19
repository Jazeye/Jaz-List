#!/bin/bash

# Define the password list sources
ROCKYOU_URL="https://raw.githubusercontent.com/brannondorsey/naive-hashcat/master/rockyou.txt"
SECLISTS_URL="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-10000.txt"
WORDLIST_URL="https://raw.githubusercontent.com/JohnTheRipper/john/bleeding-jumbo/run/wordlist.txt"
ADDITIONAL_URLS=(
  "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/rockyou.txt"
  "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/10-million-password-list-top-2000000.txt"
  "https://raw.githubusercontent.com/fiqri/wordlist/master/rockyou.txt"
  "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/english.txt"
  "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/facebook.txt"
)

# Define the protocol and extension-based wordlist options
PROTOCOLS=("SSH" "FTP" "HTTP" "SMTP" "SNMP")
EXTENSIONS=("PDF" "DOCX" "XLSX" "PPTX" "ZIP" "RAR" "7Z" "JPG" "PNG" "GIF" "BMP")

# Function to display a loading animation
loading_animation() {
  local delay=0.2
  local frames=("--" "->" "<-" "--")
  while :; do
    for frame in "${frames[@]}"; do
      printf "\rDownloading %s" "$frame"
      sleep $delay
    done
  done
}

# Function to stop the loading animation
stop_loading_animation() {
  kill "$animation_pid" 2>/dev/null
  wait "$animation_pid" 2>/dev/null
  printf "\rDone!                          \n"
}

# Function to display landing page animation
landing_page() {
  local message="Welcome to the Password List Generator and Steganography Cracker"
  local developer="Developed by Jaseel | Version $VERSION"
  local art="
 ____                                  
|  _ \ __ _ ___ ___    __ _  ___ _ __  
| |_) / _\` / __/ __|  / _\` |/ _ \ '_ \ 
|  __/ (_| \__ \__ \ | (_| |  __/ | | |
|_|   \__,_|___/___/  \__, |\___|_| |_|
                      |___/            
  "
  clear
  echo "$art"
  sleep 1
  for ((i=0; i<${#message}; i++)); do
    printf "%s" "${message:$i:1}"
    sleep 0.05
  done
  echo
  echo "$developer"
  echo
}

# Function to download and combine password lists
download_and_combine_password_lists() {
  echo "Downloading password lists..."
  
  # Start loading animation in the background
  loading_animation &
  animation_pid=$!

  # Define temp file
  local temp_file=$(mktemp)

  # Download lists
  curl -s $ROCKYOU_URL >> $temp_file
  curl -s $SECLISTS_URL >> $temp_file
  curl -s $WORDLIST_URL >> $temp_file

  # Download additional sources
  for url in "${ADDITIONAL_URLS[@]}"; do
    curl -s $url >> $temp_file
  done

  # Stop the loading animation
  stop_loading_animation

  # Check if download was successful
  if [ ! -s "$temp_file" ]; then
    echo "Failed to download password lists."
    rm -f "$temp_file"
    exit 1
  fi

  # Remove duplicates and sort
  combined_list=$(sort -u "$temp_file")
  rm -f "$temp_file"
  echo "$combined_list"
}

# Function to filter password list based on protocol or extension
filter_password_list() {
  local protocol=$1
  local extension=$2
  local password_list=$3
  if [ -n "$protocol" ]; then
    filtered_list=$(echo "$password_list" | grep -Ei "$protocol")
  elif [ -n "$extension" ]; then
    filtered_list=$(echo "$password_list" | grep -Ei "$extension")
  else
    filtered_list=$password_list
  fi

  # Ensure at least 10,000 passwords
  if [ $(echo "$filtered_list" | wc -l) -lt 100000 ]; then
    echo "Filtered list contains fewer than 10,000 passwords. Extending list..."
    filtered_list=$(echo "$password_list" | shuf | head -n 100000)
  fi

  # Check if filtering was successful
  if [ -z "$filtered_list" ]; then
    echo "No passwords matched the filter criteria."
  fi

  echo "$filtered_list"
}

# Function to generate a custom wordlist with at least 10,000 unique passwords
generate_custom_wordlist() {
  local length=$1
  local charset=$2
  local num_passwords=100000
  local password_list=()
  
  while [ ${#password_list[@]} -lt $num_passwords ]; do
    password=$(generate_random_password "$length" "$charset")
    password_list+=("$password")
  done
  
  # Remove duplicates and print the list
  unique_passwords=$(printf "%s\n" "${password_list[@]}" | sort -u)
  echo "$unique_passwords"
}

# Helper function to generate a random password
generate_random_password() {
  local length=$1
  local charset=$2
  local password=""
  for ((i=0; i<$length; i++)); do
    password+=$(echo -n "${charset:$(( RANDOM % ${#charset} )):1}")
  done
  echo "$password"
}

# Function to crack steganography images
crack_steganography_image() {
  local image_file=$1
  local password_list=$2
  local cracked_password=""
  for password in $password_list; do
    if steghide extract -sf $image_file -p $password; then
      cracked_password=$password
      break
    fi
  done
  echo "$cracked_password"
}

# Function to save the password list to a file
save_to_file() {
  local filename=$1
  local content=$2
  if [ -n "$content" ]; then
    echo "$content" > "$filename"
    echo "Password list saved to $filename"
  else
    echo "No content to save to $filename"
  fi
}

# Main function
main() {
  landing_page
  
  echo "Password List Generator and Steganography Cracker"
  echo "-----------------------------------------------"
  echo "Choose an option:"
  echo "1. Create a protocol-based wordlist"
  echo "2. Create an extension-based wordlist"
  echo "3. Create a custom wordlist"
  echo "4. Generate a random wordlist"
  echo "5. Crack a steganography image"
  read -p "Enter your choice: " choice

  case $choice in
    1)
      echo "Choose a protocol:"
      for i in "${!PROTOCOLS[@]}"; do
        echo "$((i+1)). ${PROTOCOLS[$i]}"
      done
      read -p "Enter your choice: " protocol_choice
      protocol=${PROTOCOLS[$((protocol_choice-1))]}
      password_list=$(download_and_combine_password_lists)
      filtered_list=$(filter_password_list "$protocol" "" "$password_list")
      save_to_file "${protocol}_wordlist.txt" "$filtered_list"
      ;;
    2)
      echo "Choose an extension:"
      for i in "${!EXTENSIONS[@]}"; do
        echo "$((i+1)). ${EXTENSIONS[$i]}"
      done
      read -p "Enter your choice: " extension_choice
      extension=${EXTENSIONS[$((extension_choice-1))]}
      password_list=$(download_and_combine_password_lists)
      filtered_list=$(filter_password_list "" "$extension" "$password_list")
      save_to_file "${extension}_wordlist.txt" "$filtered_list"
      ;;
    3)
      echo "Enter a custom filter (e.g. 'ssh' or '.pdf'): "
      read -p "Enter your filter: " custom_filter
      password_list=$(download_and_combine_password_lists)
      filtered_list=$(filter_password_list "" "" "$password_list" | grep -Ei "$custom_filter")
      save_to_file "${custom_filter}_wordlist.txt" "$filtered_list"
      ;;
    4)
      echo "Enter the length of the wordlist: "
      read -p "Enter the length: " length
      echo "Enter the character set (e.g. 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()'): "
      read -p "Enter the character set: " charset
      random_list=$(generate_custom_wordlist "$length" "$charset")
      save_to_file "random_wordlist.txt" "$random_list"
      ;;
    5)
      echo "Enter the path to the image file: "
      read -p "Enter image file path: " image_file
      password_list=$(download_and_combine_password_lists)
      cracked_password=$(crack_steganography_image "$image_file" "$password_list")
      if [ -n "$cracked_password" ]; then
        echo "Cracked password: $cracked_password"
      else
        echo "No password found."
      fi
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
}

# Run the main function
main
