-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Categories Table
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT 'bg-indigo-500',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create Books Table
CREATE TABLE IF NOT EXISTS public.books (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  category_name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  rating NUMERIC(3,2) DEFAULT 4.5,
  reviews_count INTEGER DEFAULT 0,
  cover_url TEXT NOT NULL,
  description TEXT NOT NULL,
  is_bestseller BOOLEAN DEFAULT false,
  stock INTEGER DEFAULT 10,
  pages INTEGER DEFAULT 250,
  published_year INTEGER DEFAULT 2024,
  isbn TEXT UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount NUMERIC(10,2) NOT NULL,
  status TEXT CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')) DEFAULT 'Processing',
  shipping_address TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Ensure orders user_id is nullable for guest orders
ALTER TABLE public.orders ALTER COLUMN user_id DROP NOT NULL;

-- Create Order Items Table
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  book_id UUID REFERENCES public.books(id) ON DELETE SET NULL,
  book_title TEXT NOT NULL,
  book_cover TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0)
);

-- Seed Categories
INSERT INTO public.categories (id, name, icon, description, color) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Fiction', 'menu_book', 'Engaging novels, classical literature, and storytelling masterpieces.', 'bg-indigo-500'),
  ('c1000000-0000-0000-0000-000000000002', 'Psychology', 'psychology', 'Human behavior, habit building, mindset, and self-improvement.', 'bg-sky-500'),
  ('c1000000-0000-0000-0000-000000000003', 'Technology', 'computer', 'Software engineering, AI development, and digital technology trends.', 'bg-emerald-500'),
  ('c1000000-0000-0000-0000-000000000004', 'History', 'history_edu', 'Historical events, civilizations, memoirs, and world archaeology.', 'bg-amber-500'),
  ('c1000000-0000-0000-0000-000000000005', 'Science Fiction', 'rocket_launch', 'Futuristic worlds, space exploration, and sci-fi adventures.', 'bg-purple-500'),
  ('c1000000-0000-0000-0000-000000000006', 'Art & Design', 'palette', 'Graphic design principles, visual arts, and architectural aesthetics.', 'bg-pink-500')
ON CONFLICT (id) DO NOTHING;

-- Seed Books
INSERT INTO public.books (id, title, author, category_id, category_name, price, rating, reviews_count, cover_url, description, is_bestseller, stock, pages, published_year, isbn) VALUES
  ('b1000000-0000-0000-0000-000000000001', 'The Midnight Library', 'Matt Haig', 'c1000000-0000-0000-0000-000000000001', 'Fiction', 19.99, 4.8, 1240, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400', 'Between life and death there is a library, and within that library, the shelves go on forever.', true, 15, 304, 2020, '978-0525559474'),
  ('b1000000-0000-0000-0000-000000000002', 'Atomic Habits', 'James Clear', 'c1000000-0000-0000-0000-000000000002', 'Psychology', 22.00, 4.9, 3820, 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&q=80&w=400', 'An Easy & Proven Way to Build Good Habits & Break Bad Ones.', true, 25, 320, 2018, '978-0735211292'),
  ('b1000000-0000-0000-0000-000000000003', 'Station Eleven', 'Emily St. John Mandel', 'c1000000-0000-0000-0000-000000000001', 'Fiction', 14.50, 4.6, 890, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400', 'An audacious novel set in the eerie days of Civilization''s collapse.', true, 8, 336, 2014, '978-0804172448'),
  ('b1000000-0000-0000-0000-000000000004', 'Circe', 'Madeline Miller', 'c1000000-0000-0000-0000-000000000001', 'Fiction', 12.99, 4.7, 1560, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=400', 'In the house of Helios, god of the sun, a daughter is born.', true, 12, 400, 2018, '978-0316556347'),
  ('b1000000-0000-0000-0000-000000000005', 'Clean Code', 'Robert C. Martin', 'c1000000-0000-0000-0000-000000000003', 'Technology', 34.99, 4.8, 2150, 'https://images.unsplash.com/photo-1516116211223-4c71424a3190?auto=format&fit=crop&q=80&w=400', 'A handbook of agile software craftsmanship for writing maintainable code.', false, 20, 464, 2008, '978-0132350884'),
  ('b1000000-0000-0000-0000-000000000006', 'Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 'c1000000-0000-0000-0000-000000000004', 'History', 24.50, 4.9, 4100, 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?auto=format&fit=crop&q=80&w=400', 'Explore how biology and history have defined us and enhanced our understanding of humankind.', true, 30, 443, 2015, '978-0062316097'),
  ('b1000000-0000-0000-0000-000000000007', 'Dune', 'Frank Herbert', 'c1000000-0000-0000-0000-000000000005', 'Science Fiction', 18.00, 4.9, 5200, 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?auto=format&fit=crop&q=80&w=400', 'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides.', true, 18, 688, 1965, '978-0441172719'),
  ('b1000000-0000-0000-0000-000000000008', 'The Design of Everyday Things', 'Don Norman', 'c1000000-0000-0000-0000-000000000006', 'Art & Design', 16.75, 4.7, 980, 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&q=80&w=400', 'Even the smartest among us can feel inept as we try to figure out which light switch to turn on.', false, 10, 368, 2013, '978-0465050659')
ON CONFLICT (id) DO NOTHING;

-- Row Level Security (RLS)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Categories are viewable by everyone" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Books are viewable by everyone" ON public.books FOR SELECT USING (true);

CREATE POLICY "Anyone can create orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can update own orders" ON public.orders FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Anyone can create order items" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can view order items" ON public.order_items FOR SELECT USING (true);
