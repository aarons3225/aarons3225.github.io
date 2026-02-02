---
title: "ReviewGap: Identifying Documentation Gaps Before They Become Tickets"
date: 2026-01-31 00:00:00 -0500
categories: projects/reviewgap
tags:
  - project
  - python
  - automation
  - documentation
---

## The Problem

Support teams know the frustration: users submit tickets for issues that *should* be covered in documentation—but aren't, or are buried where no one finds them. Meanwhile, documentation teams don't always know which gaps are causing the most pain until the ticket queue tells them (too late).

## What I Built

ReviewGap is a Python tool that analyzes product reviews to surface recurring complaints that documentation could address. Instead of waiting for tickets to pile up, it identifies patterns in customer feedback and prioritizes which support articles would have the most impact.

### How It Works

1. **Ingests review data** from product feedback sources
2. **Filters out noise** — general complaints, shipping issues, and other non-documentation problems
3. **Clusters similar issues** — so you see "15 users struggled with password reset" instead of 15 separate complaints
4. **Prioritizes by impact** — frequency matters, but critical issues like security or data loss get flagged immediately

### Results

Testing against real review data cut analysis time from over an hour to about four minutes while producing cleaner, more actionable output.

## Why This Matters for Support

Good documentation reduces ticket volume. But knowing *what* to document—and what's missing—usually requires digging through support history manually. This tool automates that discovery process.

## What I Learned

The first version captured everything, which made the output overwhelming and not particularly useful. Adding relevance filtering taught me that raw data isn't insight—you need to design for the *right* data. That same principle applies to troubleshooting: knowing what to ignore is as important as knowing what to investigate.

## Link

The link to the GitHub Repo is here:
[Review Gap](https://github.com/aarons3225/reviewgap)