# 📚 PageTurn - Flutter Online Bookstore App

A complete, production-ready Flutter mobile application for an online bookstore powered by **Supabase** backend. Built to fulfill course project requirements and showcase best practices in cross-platform mobile development using Flutter and Dart.

---

## 🚀 Key Features

* **Authentication & Supabase Auth**: Secure Email & Password Login and Sign Up with real-time session persistence, input validation, and user profile creation.
* **Best Sellers Hub**: Instant view post-login featuring top-rated books, interactive carousel, search filter, and quick cart addition.
* **Book Categories**: Dynamic category exploration (Technology, Fiction, Self-Improvement, Science, Business, Fantasy) with live filter counters.
* **Book Details View**: Comprehensive view with book covers, stock indicator, page count, published year, ISBN, author details, synopsis, and instant cart integration.
* **Interactive Cart & Local Storage**: Cart state management powered by Provider / Riverpod with persistent caching using `SharedPreferences`.
* **Orders Management & Full CRUD**: Real-time order placement, status tracking (Processing, Shipped, Delivered, Cancelled), order cancellation, and purchase history stored in Supabase `orders` and `order_items` tables.
* **Form Validation & Error Handling**: Robust client-side validation for emails, passwords, addresses, and asynchronous API error recovery with custom SnackBars.

---

## 🎓 Course Topics Checklist

This project explicitly incorporates all required course topics:

- [x] **Flutter Widgets & Layouts**: `Scaffold`, `CustomScrollView`, `SliverAppBar`, `GridView.builder`, `ListView.separated`, `Hero` animations, custom responsive layout wrappers.
- [x] **Navigation & Routing**: Named routes (`AppRoutes.login`, `AppRoutes.bestsellers`, `AppRoutes.cart`, `AppRoutes.orders`), bottom navigation bar with index state.
- [x] **State Management**: Clean state separation using `ChangeNotifierProvider` / `Riverpod` for Auth, Cart, Books, and Orders.
- [x] **API & Supabase Integration**: Real-time client initialization using `supabase_flutter` SDK with Supabase Auth, PostgreSQL tables, and Row Level Security (RLS).
- [x] **Local Storage**: `SharedPreferences` for offline cart caching, theme settings, and remember-me credentials.
- [x] **CRUD Operations**:
  - **Create**: Register user profile, place new order, add items to cart.
  - **Read**: Fetch best sellers, categories, book detail, user orders.
  - **Update**: Update cart quantity, modify shipping address, update order status.
  - **Delete**: Remove items from cart, cancel pending order.
- [x] **Form Validation**: `Form` widget with `GlobalKey<FormState>`, custom regex email validator, password length checks.
- [x] **Asynchronous Programming**: `FutureBuilder`, `StreamBuilder`, `async / await`, `Try-Catch-Finally` blocks.
- [x] **Error Handling**: Graceful error UI fallback, custom user notifications, network timeout catches.

---

## 🛠 System Architecture

```
                     +---------------------------------------+
                     |           Flutter Mobile UI           |
                     |  (Widgets, Navigation, Material 3)    |
                     +-------------------+-------------------+
                                         |
                                         v
                     +-------------------+-------------------+
                     |           State Layer             |
                     |  (Auth, Cart, Book & Order Providers) |
                     +---------+-------------------+---------+
                               |                   |
                               v                   v
            +------------------+--+             +--+------------------+
            |  Local Storage      |             |  Supabase Service   |
            | (SharedPreferences) |             |  (supabase_flutter) |
            +---------------------+             +--------+------------+
                                                         |
                                                         v
                                                +--------+------------+
                                                | Supabase Cloud DB   |
                                                |  - Auth (Users)     |
                                                |  - Books Table      |
                                                |  - Orders & Items   |
                                                +---------------------+
```

---

## 💻 Tech Stack & Dependencies

| Dependency | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter** | 3.22+ | Cross-platform UI toolkit |
| **Dart** | 3.4+ | Core programming language |
| **supabase_flutter** | ^2.5.0 | Supabase Auth & PostgreSQL DB |
| **provider** | ^6.1.2 | Reactive State Management |
| **shared_preferences** | ^2.2.3 | Persistent key-value storage |
| **google_fonts** | ^6.2.1 | Custom Material 3 typography |
| **cached_network_image** | ^3.3.1 | Smooth image caching & shimmer |
| **intl** | ^0.19.0 | Currency formatting & date parsing |

---

## 💾 Supabase Setup SQL

Run the following SQL script inside your Supabase SQL Editor:

```sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Categories Table
create table public.categories (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  icon text not null,
  description text,
  color text default 'bg-indigo-500',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create Books Table
create table public.books (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  author text not null,
  category_id uuid references public.categories(id),
  category_name text not null,
  price numeric(10,2) not null,
  rating numeric(3,2) default 4.5,
  reviews_count integer default 0,
  cover_url text not null,
  description text not null,
  is_bestseller boolean default false,
  stock integer default 10,
  pages integer default 250,
  published_year integer default 2024,
  isbn text unique,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create Orders Table
create table public.orders (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  total_amount numeric(10,2) not null,
  status text check (status in ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')) default 'Processing',
  shipping_address text not null,
  payment_method text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create Order Items Table
create table public.order_items (
  id uuid default uuid_generate_v4() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  book_id uuid references public.books(id) not null,
  book_title text not null,
  book_cover text not null,
  price numeric(10,2) not null,
  quantity integer not null check (quantity > 0)
);

-- Row Level Security (RLS) Policies
alter table public.books enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

create policy "Books are viewable by everyone" on public.books for select using (true);
create policy "Users can view own orders" on public.orders for select using (auth.uid() = user_id);
create policy "Users can create own orders" on public.orders for insert with check (auth.uid() = user_id);
create policy "Users can update own orders" on public.orders for update using (auth.uid() = user_id);
```

---

## ⚡ How to Run Locally

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-username/flutter-online-bookstore.git
   cd flutter-online-bookstore
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment / Supabase Keys**:
   Create a `.env` file or set Supabase credentials in `lib/services/supabase_service.dart`:
   ```dart
   const String SUPABASE_URL = 'YOUR_SUPABASE_URL';
   const String SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Run Application**:
   ```bash
   flutter run
   ```

---

## 👥 Team & Acknowledgments

- **Developer / Student**: Flutter Mobile Developer
- **Course**: Mobile Application Development with Flutter
- **Database Backend**: Supabase Cloud PostgreSQL
