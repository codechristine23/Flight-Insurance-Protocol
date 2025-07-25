# Flight Insurance Protocol

A decentralized flight insurance system built on Stacks blockchain using Clarity smart contracts.

## Overview

This protocol allows passengers to purchase insurance policies for their flights and automatically claim compensation in case of significant delays (120+ minutes) or cancellations.

## Features

- **Policy Purchase**: Buy insurance coverage for specific flights
- **Automated Claims**: Smart contract handles claim processing based on flight status
- **Oracle Integration**: Flight delay data reporting system
- **Transparent Pricing**: Premium calculated as 10% of coverage amount

## Contract Functions

### Public Functions

- `purchase-policy`: Buy flight insurance policy
- `report-flight-delay`: Report flight delays (owner only)
- `claim-insurance`: Process insurance claims

### Read-Only Functions

- `get-policy`: Retrieve policy details
- `get-flight-status`: Check flight delay information
- `get-total-premiums`: View total premiums collected

## Usage

1. Purchase a policy by calling `purchase-policy` with flight details
2. Monitor flight status through airline reports
3. Claim compensation automatically if eligible

## Testing

Run tests using Clarinet:
```bash
clarinet test