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
  local developer="Developed by Jaseel | Version 0.1 $VERSION"
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

# Function to generate a custom wordlist with user-defined settings
generate_custom_wordlist() {
  local length=$1
  local charset=$2
  local num_passwords=$3
  local word_or_name=$4
  local password_list=()
  
  while [ ${#password_list[@]} -lt $num_passwords ]; do
    password=$(generate_random_password "$length" "$charset" "$word_or_name")
    password_list+=("$password")
  done
  
  # Remove duplicates and print the list
  unique_passwords=$(printf "%s\n" "${password_list[@]}" | sort -u)
  echo "$unique_passwords"
}

# Helper function to generate a random password with optional included words
generate_random_password() {
  local length=$1
  local charset=$2
  local word_or_name=$3
  local password=""
  
  # Include specific word or name if provided
  if [ -n "$word_or_name" ]; then
    password+="$word_or_name"
    length=$((length - ${#word_or_name}))
  fi
  
  # Generate random part of the password
  for ((i=0; i<$length; i++)); do
    password+=$(echo -n "${charset:$(( RANDOM % ${#charset} )):1}")
  done
  echo "$password"
}

# Function to generate a random wordlist with user-defined settings
generate_random_wordlist() {
  local length=$1
  local num_passwords=$2

  echo "Generating random wordlist..."
  loading_animation &
  animation_pid=$!
  
  random_list=$(generate_custom_wordlist "$length" "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()" "$num_passwords" "")
  
  stop_loading_animation
  echo "$random_list"
}

# Function to crack steganography images with an optional verbose mode
crack_steganography_image() {
  local image_file=$1
  local password_list=$2
  local verbose=$3
  local cracked_password=""

  for password in $password_list; do
    if [ "$verbose" == "true" ]; then
      echo "Trying password: $password"
    fi
    if steghide extract -sf "$image_file" -p "$password" >/dev/null 2>&1; then
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

# Function to handle the password list generation
handle_password_list_generation() {
  local option=$1
  local length=$2
  local charset=$3
  local protocol=$4
  local extension=$5
  local custom_filter=$6

  case $option in
    1)
      echo "Choose a protocol:"
      for i in "${!PROTOCOLS[@]}"; do
        echo "$((i+1)). ${PROTOCOLS[$i]}"
      done
      read -p "Enter your choice: " protocol_choice
      protocol=${PROTOCOLS[$((protocol_choice-1))]}
      
      echo "Downloading and filtering password lists..."
      loading_animation &
      animation_pid=$!
      
      password_list=$(download_and_combine_password_lists)
      filtered_list=$(filter_password_list "$protocol" "" "$password_list")
      
      stop_loading_animation
      save_to_file "${protocol}_wordlist.txt" "$filtered_list"
      ;;
    2)
      echo "Choose an extension:"
      for i in "${!EXTENSIONS[@]}"; do
        echo "$((i+1)). ${EXTENSIONS[$i]}"
      done
      read -p "Enter your choice: " extension_choice
      extension=${EXTENSIONS[$((extension_choice-1))]}
      
      echo "Downloading and filtering password lists..."
      loading_animation &
      animation_pid=$!
      
      password_list=$(download_and_combine_password_lists)
      filtered_list=$(filter_password_list "" "$extension" "$password_list")
      
      stop_loading_animation
      save_to_file "${extension}_wordlist.txt" "$filtered_list"
      ;;
    3)
      echo "Enter the length of each password: "
      read -p "Enter the length: " length
      echo "Enter the included word or name for creating custom wordlist (leave blank for none): "
      read -p "Enter the word or name: " word_or_name
      echo "Enter the number of passwords you want to generate: "
      read -p "Enter the number: " num_passwords
      
      echo "Generating custom wordlist..."
      loading_animation &
      animation_pid=$!
      
      custom_list=$(generate_custom_wordlist "$length" "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()" "$num_passwords" "$word_or_name")
      
      stop_loading_animation
      save_to_file "custom_wordlist.txt" "$custom_list"
      ;;
    4)
      echo "Enter the length of each password: "
      read -p "Enter the length: " length
      echo "Enter the number of passwords you want to generate: "
      read -p "Enter the number: " num_passwords
      
      echo "Generating random wordlist..."
      loading_animation &
      animation_pid=$!
      
      random_list=$(generate_random_wordlist "$length" "$num_passwords")
      
      stop_loading_animation
      save_to_file "random_wordlist.txt" "$random_list"
      ;;
    5)
      echo "Enter the path to the image file: "
      read -p "Enter image file path: " image_file
      read -p "Enable verbose mode? (y/n): " verbose_choice
      verbose="false"
      if [ "$verbose_choice" == "y" ]; then
        verbose="true"
      fi
      
      echo "Downloading password lists..."
      loading_animation &
      animation_pid=$!
      
      password_list=$(download_and_combine_password_lists)
      
      stop_loading_animation
      cracked_password=$(crack_steganography_image "$image_file" "$password_list" "$verbose")
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

  handle_password_list_generation "$choice"
}

# Run the main function
main
