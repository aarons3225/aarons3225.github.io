---
title: "sed: A Useful Editor"
date: 2024-08-14 00:00:00 -0700
categories:
  - How-To
tags:
  - linux
---


# A Beginner's Guide to sed: The Stream Editor

## What is sed?

`sed` (Stream EDitor) is a powerful Unix/Linux command-line utility for parsing and transforming text. It processes text line-by-line and can perform operations like search, find and replace, insertion, and deletion without opening the file in an editor.

Think of sed as a way to automate text editing tasks that you'd normally do manually in a text editor. It's particularly useful in scripts and pipelines where you need to transform text on the fly.

## Background

- **Created**: 1973-1974 by Lee E. McMahon at Bell Labs
- **Purpose**: Non-interactive text editing for batch processing
- **Philosophy**: Works as a filter in Unix pipelines, reading from stdin and writing to stdout
- **Regex-based**: Uses regular expressions for pattern matching

## Basic Syntax

```bash
sed [OPTIONS] 'command' file
```

Or with input from a pipe:

```bash
command | sed 'command'
```

## How sed Works

1. Reads one line from the input
2. Removes the trailing newline
3. Executes the sed command(s) on that line
4. Prints the result to stdout (by default)
5. Repeats for the next line

## Common Options

| Option | Description |
|--------|-------------|
| `-i` | Edit files in-place (modifies the original file) |
| `-i.bak` | Edit in-place but create a backup with .bak extension |
| `-n` | Suppress automatic printing (use with `p` command) |
| `-e` | Allows multiple commands |
| `-r` or `-E` | Use extended regular expressions |

## Essential Commands

### The Substitution Command (s)

This is the most commonly used sed command.

**Syntax:**
```bash
s/pattern/replacement/flags
```

**Flags:**
- `g` - Replace all occurrences on a line (not just the first)
- `i` - Case-insensitive matching
- `p` - Print the line if substitution was made
- `w file` - Write lines where substitution occurred to a file
- A number (e.g., `2`) - Replace only the nth occurrence

### Other Useful Commands

- `d` - Delete lines
- `p` - Print lines
- `a` - Append text after a line
- `i` - Insert text before a line
- `c` - Replace entire lines

## Common Examples

### Example 1: Basic Find and Replace

Replace the first occurrence of "old" with "new" on each line:

```bash
sed 's/old/new/' file.txt
```

Replace all occurrences (global):

```bash
sed 's/old/new/g' file.txt
```

### Example 2: Edit File In-Place

Replace "foo" with "bar" and save changes to the file:

```bash
sed -i 's/foo/bar/g' config.txt
```

Create a backup before editing:

```bash
sed -i.backup 's/foo/bar/g' config.txt
```

### Example 3: Case-Insensitive Replacement

Replace "error" regardless of case (ERROR, Error, error):

```bash
sed 's/error/WARNING/gi' logfile.txt
```

### Example 4: Delete Lines

Delete blank lines:

```bash
sed '/^$/d' file.txt
```

Delete lines containing a specific pattern:

```bash
sed '/pattern/d' file.txt
```

Delete lines 5 through 10:

```bash
sed '5,10d' file.txt
```

### Example 5: Print Specific Lines

Print only line 5:

```bash
sed -n '5p' file.txt
```

Print lines 10 through 20:

```bash
sed -n '10,20p' file.txt
```

Print lines matching a pattern:

```bash
sed -n '/pattern/p' file.txt
```

### Example 6: Multiple Substitutions

Using multiple `-e` options:

```bash
sed -e 's/foo/bar/g' -e 's/old/new/g' file.txt
```

Or using semicolons:

```bash
sed 's/foo/bar/g; s/old/new/g' file.txt
```

### Example 7: Working with Delimiters

When your pattern contains slashes, use a different delimiter:

```bash
# Instead of escaping: s/\/usr\/local\/bin/\/opt\/bin/g
sed 's|/usr/local/bin|/opt/bin|g' file.txt
```

You can use any character as a delimiter: `|`, `#`, `:`, etc.

### Example 8: Using Regular Expressions

Replace any number with "NUM":

```bash
sed 's/[0-9]\+/NUM/g' file.txt
```

Remove leading whitespace:

```bash
sed 's/^[ \t]*//' file.txt
```

Remove trailing whitespace:

```bash
sed 's/[ \t]*$//' file.txt
```

### Example 9: Backreferences

Swap two words:

```bash
echo "hello world" | sed 's/\(.*\) \(.*\)/\2 \1/'
# Output: world hello
```

Add quotes around a word:

```bash
sed 's/\(error\)/"\1"/g' file.txt
```

### Example 10: Address Ranges

Replace only on lines 1-5:

```bash
sed '1,5s/old/new/g' file.txt
```

Replace from first match to end of file:

```bash
sed '/start-pattern/,$s/old/new/g' file.txt
```

### Example 11: Insert and Append Text

Insert text before line 3:

```bash
sed '3i\This is inserted text' file.txt
```

Append text after line matching pattern:

```bash
sed '/pattern/a\This text is appended' file.txt
```

### Example 12: Practical Homelab Examples

Replace all IP addresses in a config file:

```bash
sed -i 's/192\.168\.1\./10\.0\.0\./g' network.conf
```

Comment out lines in a configuration file:

```bash
sed 's/^/# /' config.txt
```

Uncomment lines:

```bash
sed 's/^# //' config.txt
```

Extract email addresses from a file:

```bash
sed -n 's/.*\([a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}\).*/\1/p' file.txt
```

## Tips and Best Practices

1. **Test first**: Always test your sed command without `-i` to see the output before modifying files
2. **Use backups**: When using `-i`, create backups with `-i.bak`
3. **Quote your commands**: Use single quotes to prevent shell interpretation
4. **Start simple**: Begin with basic substitutions and build complexity
5. **Combine with other tools**: sed works great with `grep`, `awk`, `cut`, and pipes

## Common Pitfalls

- Forgetting the `g` flag and only replacing the first occurrence
- Not escaping special regex characters (`.`, `*`, `[`, `]`, etc.)
- Using `-i` without testing first and losing data
- Confusing basic and extended regex syntax

## Where to Go Next

- Learn `awk` for more complex text processing
- Study regular expressions in depth
- Explore `perl` one-liners for even more powerful text manipulation
- Check the man page: `man sed`

## Quick Reference Card

```bash
# Basic substitution
sed 's/find/replace/' file

# Global substitution
sed 's/find/replace/g' file

# Case-insensitive
sed 's/find/replace/gi' file

# Edit in-place
sed -i 's/find/replace/g' file

# Delete lines
sed '/pattern/d' file

# Print only matching lines
sed -n '/pattern/p' file

# Multiple commands
sed -e 's/a/A/g' -e 's/b/B/g' file
```

Happy sed-ing!
