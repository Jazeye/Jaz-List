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
  local developer="Developed by Jaseel | Version 0.1"
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
  if [ $(echo "$filtered_list" | wc -l) -lt 10000 ]; then
    echo "Filtered list contains fewer than 10,000 passwords. Extending list..."
    filtered_list=$(echo "$password_list" | shuf | head -n 10000)
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
  local temp_file=$(mktemp)
  loading_animation &
  animation_pid=$!

  random_list=$(generate_custom_wordlist "$length" "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()" "$num_passwords" "")

  stop_loading_animation
  echo "$random_list" > "$temp_file"

  # Ensure the random list contains names, numbers, and patterns
  sed -i '/^[0-9]*$/d' "$temp_file"  # Remove lines with only numbers
  sed -i '/^[a-zA-Z]*$/d' "$temp_file" # Remove lines with only letters
  echo "$random_list" >> "$temp_file"

  cat "$temp_file"
  rm -f "$temp_file"
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
  local num_passwords=$4
  local word_or_name=$5

  case $option in
    "random")
      generate_random_wordlist "$length" "$num_passwords"
      ;;
    "custom")
      generate_custom_wordlist "$length" "$charset" "$num_passwords" "$word_or_name"
      ;;
    *)
      echo "Invalid option. Please choose 'random' or 'custom'."
      ;;
  esac
}

# Function to handle protocol and extension-based password lists
handle_protocol_extension() {
  local protocol=$1
  local extension=$2
  local password_list=$3
  local filtered_list=$(filter_password_list "$protocol" "$extension" "$password_list")
  
  echo "Filtered list:"
  echo "$filtered_list"
}

# Function to display the help menu
display_help() {
  echo "Usage: $0 [OPTION] [ARGS...]"
  echo
  echo "Options:"
  echo "  -h, --help                   Show this help message and exit"
  echo "  -g, --generate <type>        Generate password list. <type> can be 'random' or 'custom'."
  echo "  -f, --file <filename>        Save the generated list to <filename>"
  echo "  -p, --protocol <protocol>    Filter password list by protocol"
  echo "  -e, --extension <extension>  Filter password list by extension"
  echo "  -i, --image <image_file>     Crack steganography image with given password list"
  echo "  -v, --verbose                Enable verbose mode for steganography cracking"
  echo "  -l, --length <length>        Length of passwords for generation"
  echo "  -c, --charset <charset>      Charset for custom wordlist"
  echo "  -n, --number <number>        Number of passwords to generate"
  echo "  -w, --word <word>            Word to include in passwords"
  echo
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      display_help
      ;;
    -g|--generate)
      shift
      handle_password_list_generation "$1" "$2" "$3" "$4" "$5"
      shift 4
      ;;
    -f|--file)
      shift
      filename=$1
      save_to_file "$filename" "$output"
      shift
      ;;
    -p|--protocol)
      shift
      protocol=$1
      handle_protocol_extension "$protocol" "" "$password_list"
      shift
      ;;
    -e|--extension)
      shift
      extension=$1
      handle_protocol_extension "" "$extension" "$password_list"
      shift
      ;;
    -i|--image)
      shift
      image_file=$1
      shift
      password_list=$(download_and_combine_password_lists)
      cracked_password=$(crack_steganography_image "$image_file" "$password_list" "$verbose")
      echo "Cracked password: $cracked_password"
      shift
      ;;
    -v|--verbose)
      verbose="true"
      shift
      ;;
    -l|--length)
      shift
      length=$1
      shift
      ;;
    -c|--charset)
      shift
      charset=$1
      shift
      ;;
    -n|--number)
      shift
      num_passwords=$1
      shift
      ;;
    -w|--word)
      shift
      word_or_name=$1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      display_help
      ;;
  esac
done
