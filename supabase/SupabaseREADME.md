# UMeal Database (Supabase)

## Overview
UMeal uses **Supabase**, an open-source Firebase alternative, as its backend-as-a-service. It provides a PostgreSQL database with built-in authentication, real-time subscriptions, and row-level security (RLS). This document outlines the core tables and their relationships[reference:2].

## Core Schema

The database consists of tables for user management, meal data, and user interactions. Row Level Security (RLS) is enabled on all tables to ensure data privacy and security.

### `user_profile`
Stores application-specific user data linked to Supabase Auth.
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_id` (PK) | `uuid` | References `auth.users`. The primary key. |
| `full_name` | `text` | User's full display name. |
| `max_calories` | `integer` | User's daily calorie limit. |
| `min_protein` | `integer` | User's daily protein goal. |
| `allergies` | `text[]` | Array of user allergies. |
| `preferences` | `text` | JSON or text field for other preferences. |

### `meals_list`
The main catalog of all meals and recipes in the system.
| Column | Type | Description |
| :--- | :--- | :--- |
| `meal_id` (PK) | `uuid` | Unique identifier, default `gen_random_uuid()`. |
| ... | ... | Other fields include name, description, nutritional info, etc. |

### `dining_halls`
Stores information about different dining locations on campus.
| Column | Type | Description |
| :--- | :--- | :--- |
| `dc_id` (PK) | `bigint` | UMass dining commons identifier. |
| `dc_name` | `text` | Name of the dining hall (e.g., Berkshire, Worcester). |
| `hour_open` / `hour_closed` | `time` | Operating hours. |
| `payment_accepted` | `jsonb` | Accepted payment methods. |

### `favorite_meals`
Junction table managing user-saved meals.
| Column | Type | Description |
| :--- | :--- | :--- |
| `saved_meal_id` (PK) | `bigint` | Unique identifier for the saved item. |
| `user_id` (FK) | `uuid` | References `user_profile.user_id`. |
| `meal_id` (FK) | `uuid` | References `meals_list.meal_id`. |
| `saved_at` | `timestamptz` | Timestamp of when it was saved. |

### `meal_log`
Tracks meals that a user has eaten.
| Column | Type | Description |
| :--- | :--- | :--- |
| `log_id` (PK) | `bigint` | Unique identifier for the log entry. |
| `user_id` (FK) | `uuid` | References `user_profile.user_id`. |
| `meal_id` (FK) | `uuid` | References `meals_list.meal_id`. |
| `eaten_date` | `date` | Date the meal was consumed. |

## Local Setup & Migrations

1.  **Clone the repository** and navigate to the root directory.
2.  **Install Supabase CLI** and **link** your local project to your Supabase project.
3.  **Apply Migrations:** The project's database schema is version-controlled and managed through migration files in the `/supabase/migrations` folder.
   ```bash
   supabase db push
