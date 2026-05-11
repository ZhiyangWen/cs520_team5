# UMeal - CS520 Final Project

## Overview
For most college students, eating in a way that supports their health goals is always difficult. Tracking protein, avoiding allergens, or balancing calories can be very complicated when most meals come from a dining hall. Apps like MyFitnessPal exist, but they are not helpful for campus dining, so Five College students don't have a tool that actually fits how they eat in the daily life. The App we are building brings together recipe search, nutrition filtering, and live UMass dining hall menus into one place, so students can find meals that match their goals whether they're cooking at home or grabbing food on campus. 

## Tech Stack
**Front end:** Swift/SwiftUI

**Database:** Supabase
    - Supabase is well documented and integrates well with Swift for iPhone apps
    
**Platform:** IOS (Iphone)
    - UMeal is a mobile app, and since most of us have IPhones, we decided to build for iOS using Swift

## Team Roles
| Role | Members |
|------|---------|
| Frontend | Shriya, Zhiyang |
| Backend | TBD |
| Database | Cassandra, Pornnapin |

## System Features
Meal/Recipe Search Page with Filters

User Personal Profiles

New Recipe Page

Login Page

Register Page

Landing Page

Saved Recipes

Notifications

## How to Run the Project

### Requirements
- Mac with Xcode 15.4 or later

### Steps
1. Clone the repository
   git clone https://github.com/ZhiyangWen/cs520_team5.git

2. Navigate to the frontend
   cd cs520_team5/src/Frontend

3. Open the project in Xcode
   open UMeal.xcodeproj

4. Add Supabase credentials
   - Open Instrument.swift
   - Add your Supabase project URL and API key
  
5. Build and run
   - Select iPhone simulator
   - Build and run
  
## Deployment

UMeal is currently configured for local development and simulator testing using Xcode. The app runs on iOS simulator and can be deployed to physical devices via Xcode for testing purposes. App Store or TestFlight distribution has not been set up at this stage of development. The backend is powered by Supabase, which is live and accessible during development.

## Dependencies

All dependencies are managed via Swift Package Manager (SPM) and are
automatically resolved when the project is opened in Xcode.

| Package | Version |
|---------|---------|
| supabase-swift | 2.46.0 |
| SwiftSoup | 2.13.4 |
| swift-crypto | 4.5.0 |
| swift-http-types | 1.5.1 |
| swift-clocks | 1.0.6 |
| swift-concurrency-extras | 1.3.2 |
| swift-asn1 | 1.7.0 |
| xctest-dynamic-overlay | 1.9.0 |

Full dependency details are available in `Package.resolved`.

## Additional Documentation
- [Frontend Documentation](src/Frontend/FrontendREADME.md)
- [Database Documentation](supabase/SupabaseREADME.md)
- [Testing Documentation](src/Frontend/UMealTests/TestsREADME.md)
- [API Documentation](docs/index.html)



