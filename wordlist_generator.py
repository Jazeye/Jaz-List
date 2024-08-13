#!/usr/bin/env python3
import argparse
from wordlist_generator.generator import create_wordlist

def main():
    parser = argparse.ArgumentParser(description="Wordlist Generator Tool")
    parser.add_argument("-w", "--wordlists", nargs="+", required=True, help="Paths to input wordlists")
    parser.add_argument("-o", "--output", required=True, help="Path to save the combined wordlist")
    parser.add_argument("-p", "--permutations", action="store_true", help="Apply permutations to words")
    parser.add_argument("-s", "--substitutions", action="store_true", help="Apply character substitutions")

    args = parser.parse_args()

    create_wordlist(args.wordlists, args.output, apply_perm=args.permutations, apply_subs=args.substitutions)

if __name__ == "__main__":
    main()
