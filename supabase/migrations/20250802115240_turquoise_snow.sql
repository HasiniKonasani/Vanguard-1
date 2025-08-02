/*
  # Create users table for authentication

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `username` (text, unique)
      - `password` (text)
      - `full_name` (text)
      - `role` (text, check constraint for admin/teacher/dorm_parent)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `users` table
    - Add policies for authenticated users to manage user data
    - Add trigger for updated_at timestamp

  3. Default Data
    - Insert default admin user
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  password text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'teacher',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT users_role_check CHECK (role IN ('admin', 'teacher', 'dorm_parent'))
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can read users"
  ON users
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can insert users"
  ON users
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update users"
  ON users
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete users"
  ON users
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.triggers
    WHERE trigger_name = 'update_users_updated_at'
  ) THEN
    CREATE TRIGGER update_users_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Insert default admin user
INSERT INTO users (username, password, full_name, role)
VALUES ('Vanguard', 'iDontKnow', 'Vanguard Administrator', 'admin')
ON CONFLICT (username) DO NOTHING;