-- Additional tables for blog functionality (optional enhancement)

-- Blog Posts Table
CREATE TABLE blog_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    featured_image_url VARCHAR(500),
    tags TEXT[] DEFAULT '{}',
    reading_time INTEGER, -- in minutes
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics Tables
CREATE TABLE portfolio_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    page VARCHAR(100) NOT NULL,
    user_agent TEXT,
    referrer VARCHAR(500),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE portfolio_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    properties JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contact Messages Table
CREATE TABLE contact_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(200),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    replied_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Testimonials Table (for future enhancement)
CREATE TABLE testimonials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(100),
    company VARCHAR(100),
    content TEXT NOT NULL,
    avatar_url VARCHAR(500),
    rating INTEGER DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_blog_posts_published ON blog_posts(is_published, published_at DESC);
CREATE INDEX idx_blog_posts_slug ON blog_posts(slug);
CREATE INDEX idx_analytics_page ON portfolio_analytics(page);
CREATE INDEX idx_analytics_timestamp ON portfolio_analytics(timestamp DESC);
CREATE INDEX idx_events_name ON portfolio_events(event_name);
CREATE INDEX idx_contact_messages_read ON contact_messages(is_read);
CREATE INDEX idx_testimonials_featured ON testimonials(is_featured);

-- Enable Row Level Security
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for published posts" ON blog_posts
    FOR SELECT USING (is_published = true);

CREATE POLICY "Enable insert access for analytics" ON portfolio_analytics
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable insert access for events" ON portfolio_events
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable insert access for contact messages" ON contact_messages
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable read access for testimonials" ON testimonials
    FOR SELECT USING (is_active = true);

-- Analytics summary function
CREATE OR REPLACE FUNCTION get_analytics_summary()
RETURNS TABLE(
    total_visits BIGINT,
    unique_pages BIGINT,
    top_pages JSONB,
    recent_visits JSONB
) LANGUAGE sql SECURITY DEFINER AS $$
    SELECT 
        (SELECT COUNT(*) FROM portfolio_analytics) as total_visits,
        (SELECT COUNT(DISTINCT page) FROM portfolio_analytics) as unique_pages,
        (SELECT jsonb_agg(jsonb_build_object('page', page, 'count', count)) 
         FROM (SELECT page, COUNT(*) as count FROM portfolio_analytics 
               GROUP BY page ORDER BY count DESC LIMIT 5) t) as top_pages,
        (SELECT jsonb_agg(jsonb_build_object('page', page, 'timestamp', timestamp))
         FROM (SELECT page, timestamp FROM portfolio_analytics 
               ORDER BY timestamp DESC LIMIT 10) t) as recent_visits
$$;
