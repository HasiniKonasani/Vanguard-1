import { User } from '../types/auth'

// Default admin user
const defaultAdmin: User = {
  id: 'admin-1',
  username: 'Vanguard',
  password: 'iDontKnow',
  role: 'admin',
  full_name: 'Vanguard Administrator',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
}

// In-memory user storage (in production, this would be in a database)
let users: User[] = [defaultAdmin]

export const authenticateUser = (username: string, password: string): User | null => {
  const user = users.find(u => u.username === username && u.password === password)
  return user || null
}

export const getAllUsers = (): User[] => {
  return users.filter(u => u.role !== 'admin') // Don't show admin in user list
}

export const createUser = (userData: Omit<User, 'id' | 'created_at' | 'updated_at'>): User => {
  const newUser: User = {
    ...userData,
    id: `user-${Date.now()}`,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
  users.push(newUser)
  return newUser
}

export const updateUser = (id: string, updates: Partial<User>): User | null => {
  const userIndex = users.findIndex(u => u.id === id)
  if (userIndex === -1) return null
  
  users[userIndex] = {
    ...users[userIndex],
    ...updates,
    updated_at: new Date().toISOString()
  }
  return users[userIndex]
}

export const deleteUser = (id: string): boolean => {
  const userIndex = users.findIndex(u => u.id === id)
  if (userIndex === -1) return false
  
  users.splice(userIndex, 1)
  return true
}

export const getUserById = (id: string): User | null => {
  return users.find(u => u.id === id) || null
}