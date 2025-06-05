-- Portfolio App Supabase Database Schema
-- Run these SQL commands in your Supabase SQL editor to set up the database

-- Enable Row Level Security (RLS) by default
-- You can adjust these policies based on your security requirements

-- 1. Personal Info Table
CREATE TABLE personal_info (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    about_me TEXT NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    location VARCHAR(100),
    linkedin_url VARCHAR(255),
    github_url VARCHAR(255),
    resume_url VARCHAR(500),
    profile_image_url VARCHAR(500),
    roles TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Experiences Table
CREATE TABLE experiences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    responsibilities TEXT[] DEFAULT '{}',
    skills TEXT[] DEFAULT '{}',
    icon_color VARCHAR(7), -- Hex color code
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Skills Table
CREATE TABLE skills (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    proficiency INTEGER DEFAULT 1 CHECK (proficiency >= 1 AND proficiency <= 10),
    icon_name VARCHAR(50),
    color VARCHAR(7), -- Hex color code
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Projects Table
CREATE TABLE projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    long_description TEXT,
    github_url VARCHAR(255) NOT NULL,
    live_url VARCHAR(255),
    technologies TEXT[] DEFAULT '{}',
    features TEXT[] DEFAULT '{}',
    image_url VARCHAR(500),
    screenshots TEXT[] DEFAULT '{}',
    stars INTEGER DEFAULT 0,
    commit_count INTEGER,
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('completed', 'in-progress', 'planned')),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_experiences_sort_order ON experiences(sort_order);
CREATE INDEX idx_experiences_is_active ON experiences(is_active);
CREATE INDEX idx_skills_category ON skills(category);
CREATE INDEX idx_skills_sort_order ON skills(sort_order);
CREATE INDEX idx_skills_is_active ON skills(is_active);
CREATE INDEX idx_projects_sort_order ON projects(sort_order);
CREATE INDEX idx_projects_is_active ON projects(is_active);
CREATE INDEX idx_projects_is_featured ON projects(is_featured);

-- Enable Row Level Security
ALTER TABLE personal_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Create policies (allowing public read access for portfolio data)
-- Adjust these policies based on your security requirements

-- Personal Info Policies
CREATE POLICY "Enable read access for all users" ON personal_info
    FOR SELECT USING (true);

-- Experience Policies  
CREATE POLICY "Enable read access for all users" ON experiences
    FOR SELECT USING (true);

-- Skills Policies
CREATE POLICY "Enable read access for all users" ON skills
    FOR SELECT USING (true);

-- Projects Policies
CREATE POLICY "Enable read access for all users" ON projects
    FOR SELECT USING (true);

-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_personal_info_updated_at BEFORE UPDATE ON personal_info
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_experiences_updated_at BEFORE UPDATE ON experiences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data insertion (optional)
-- You can customize this data or insert your own

-- Insert personal info
INSERT INTO personal_info (
    name, title, about_me, email, phone, location, 
    linkedin_url, github_url, resume_url, 
    roles
) VALUES (
    'Aman Sikarwar',
    'Software Developer & Data Science Student',
    'I am a passionate software developer and data science student at IIT Mandi with a focus on building intuitive and innovative applications. I enjoy exploring new technologies and solving complex problems with clean, efficient code.',
    'amansikarwaar@gmail.com',
    '+91-97199-62248',
    'IIT Mandi, India',
    'https://linkedin.com/in/amansikarwar',
    'https://github.com/amansikarwar',
    'https://drive.google.com/uc?export=download&id=1_zo9UeF5xL92jeO3urnEOvCZxAdnJVei',
    ARRAY['Software Developer', 'Mobile App Developer', 'Python Programmer', 'Data Science Enthusiast', 'Flutter Expert', 'Web Developer']
);

-- Insert experiences
INSERT INTO experiences (
    company, role, duration, start_date, end_date, description,
    responsibilities, skills, icon_color, sort_order
) VALUES 
(
    'Syncubator',
    'Software Development Intern',
    'August 2024 - Present',
    '2024-08-01',
    NULL,
    'Developing cross-platform applications for neonatal incubator',
    ARRAY[
        'Developing cross-platform mobile and console display applications for a next-generation neonatal incubator using Flutter and Dart.',
        'Architecting cloud infrastructure with AWS (S3, EC2, Lambda, DynamoDB, API Gateway) for real-time data sync and secure storage.',
        'Building embedded Linux applications for incubator control systems.'
    ],
    ARRAY['Flutter', 'Dart', 'AWS', 'Embedded Linux'],
    '#64FFDA',
    1
),
(
    'Inter IIT Tech Meet, IIT Madras',
    'Back-end Developer',
    'October 2023 - December 2023',
    '2023-10-01',
    '2023-12-01',
    'Backend development for hackathon project',
    ARRAY[
        'Developed backend for Trumio using FastAPI and Python.',
        'Integrated an AI chatbot with Langchain framework.',
        'Contributed to the team that secured a top position in the hackathon.'
    ],
    ARRAY['Python', 'FastAPI', 'Langchain', 'AI'],
    '#FF7597',
    2
);

-- Insert skills
INSERT INTO skills (name, category, proficiency, icon_name, sort_order) VALUES
('Flutter', 'Mobile Development', 9, 'flutter', 1),
('Dart', 'Programming Languages', 9, 'dart', 2),
('Python', 'Programming Languages', 8, 'python', 3),
('JavaScript', 'Programming Languages', 7, 'js', 4),
('React', 'Web Development', 7, 'react', 5),
('Node.js', 'Backend Development', 6, 'node', 6),
('AWS', 'Cloud Services', 7, 'aws', 7),
('Firebase', 'Backend Services', 8, 'firebase', 8),
('Git', 'Tools & Technologies', 8, 'git', 9),
('Docker', 'DevOps', 6, 'docker', 10),
('HTML', 'Web Development', 8, 'html', 11),
('CSS', 'Web Development', 8, 'css', 12),
('Linux', 'Operating Systems', 7, 'linux', 13),
('FastAPI', 'Backend Development', 7, 'api', 14),
('Machine Learning', 'Data Science', 6, 'brain', 15);

-- Insert sample projects (you can add your actual projects)
INSERT INTO projects (
    title, description, github_url, technologies, 
    features, stars, is_featured, sort_order
) VALUES
(
    'Portfolio Website',
    'A responsive portfolio website built with Flutter Web featuring dynamic content management through Supabase.',
    'https://github.com/amansikarwar/portfolio_app',
    ARRAY['Flutter', 'Dart', 'Supabase', 'Provider'],
    ARRAY['Responsive Design', 'Dynamic Content', 'Dark Theme', 'Smooth Animations'],
    5,
    true,
    1
),
(
    'Sample Mobile App',
    'A cross-platform mobile application showcasing modern Flutter development practices.',
    'https://github.com/amansikarwar/sample-app',
    ARRAY['Flutter', 'Firebase', 'Provider', 'REST API'],
    ARRAY['Authentication', 'Real-time Database', 'Push Notifications', 'Offline Support'],
    10,
    true,
    2
);

-- Create storage buckets (run these in Supabase Dashboard > Storage)
-- 1. Create a bucket called 'portfolio-assets'
-- 2. Set it to public if you want direct access to images
-- 3. Configure appropriate policies for file access
