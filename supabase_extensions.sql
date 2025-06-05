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

-- Error Reporting Tables
CREATE TABLE error_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    error_message TEXT NOT NULL,
    error_type VARCHAR(200),
    stack_trace TEXT,
    context VARCHAR(500),
    user_id VARCHAR(100),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('info', 'warning', 'error', 'critical')),
    environment VARCHAR(20) NOT NULL CHECK (environment IN ('development', 'staging', 'production')),
    app_version VARCHAR(50),
    platform VARCHAR(50),
    custom_data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance Monitoring Tables
CREATE TABLE performance_metrics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    label VARCHAR(200) NOT NULL,
    duration INTEGER NOT NULL, -- in milliseconds
    environment VARCHAR(20) NOT NULL CHECK (environment IN ('development', 'staging', 'production')),
    app_version VARCHAR(50),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX idx_blog_posts_published ON blog_posts(is_published, published_at DESC);
CREATE INDEX idx_blog_posts_slug ON blog_posts(slug);
CREATE INDEX idx_analytics_page ON portfolio_analytics(page);
CREATE INDEX idx_analytics_timestamp ON portfolio_analytics(timestamp DESC);
CREATE INDEX idx_events_name ON portfolio_events(event_name);
CREATE INDEX idx_contact_messages_read ON contact_messages(is_read);
CREATE INDEX idx_testimonials_featured ON testimonials(is_featured);
CREATE INDEX idx_error_reports_severity ON error_reports(severity);
CREATE INDEX idx_error_reports_environment ON error_reports(environment);
CREATE INDEX idx_error_reports_timestamp ON error_reports(timestamp);
CREATE INDEX idx_performance_metrics_label ON performance_metrics(label);
CREATE INDEX idx_performance_metrics_environment ON performance_metrics(environment);
CREATE INDEX idx_performance_metrics_timestamp ON performance_metrics(timestamp);

-- Enable Row Level Security
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_metrics ENABLE ROW LEVEL SECURITY;

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

CREATE POLICY "Allow admin read access to error reports" ON error_reports
    FOR SELECT USING (true); -- In production, restrict to admin users

CREATE POLICY "Allow insert error reports" ON error_reports
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow admin read access to performance metrics" ON performance_metrics
    FOR SELECT USING (true); -- In production, restrict to admin users

CREATE POLICY "Allow insert performance metrics" ON performance_metrics
    FOR INSERT WITH CHECK (true);

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

-- Function to get error statistics
CREATE OR REPLACE FUNCTION get_error_statistics()
RETURNS TABLE(
    total_errors BIGINT,
    critical_errors BIGINT,
    error_rate_last_24h NUMERIC,
    top_error_types JSONB,
    recent_errors JSONB
) LANGUAGE sql SECURITY DEFINER AS $$
    SELECT 
        (SELECT COUNT(*) FROM error_reports) as total_errors,
        (SELECT COUNT(*) FROM error_reports WHERE severity = 'critical') as critical_errors,
        (SELECT ROUND(
            (COUNT(*) * 100.0 / NULLIF(
                (SELECT COUNT(*) FROM portfolio_analytics WHERE timestamp > NOW() - INTERVAL '24 hours'), 
                0
            ))::numeric, 2
        ) FROM error_reports WHERE timestamp > NOW() - INTERVAL '24 hours') as error_rate_last_24h,
        (SELECT jsonb_agg(jsonb_build_object('type', error_type, 'count', count)) 
         FROM (SELECT error_type, COUNT(*) as count FROM error_reports 
               WHERE error_type IS NOT NULL
               GROUP BY error_type ORDER BY count DESC LIMIT 5) t) as top_error_types,
        (SELECT jsonb_agg(jsonb_build_object(
            'error_message', error_message, 
            'severity', severity,
            'timestamp', timestamp
        ))
         FROM (SELECT error_message, severity, timestamp FROM error_reports 
               ORDER BY timestamp DESC LIMIT 10) t) as recent_errors
$$;

-- Function to get performance statistics
CREATE OR REPLACE FUNCTION get_performance_statistics()
RETURNS TABLE(
    avg_app_startup NUMERIC,
    avg_navigation NUMERIC,
    avg_api_calls NUMERIC,
    slow_operations JSONB,
    performance_trends JSONB
) LANGUAGE sql SECURITY DEFINER AS $$
    SELECT 
        (SELECT ROUND(AVG(duration)::numeric, 2) FROM performance_metrics 
         WHERE label = 'app_startup' AND timestamp > NOW() - INTERVAL '7 days') as avg_app_startup,
        (SELECT ROUND(AVG(duration)::numeric, 2) FROM performance_metrics 
         WHERE label LIKE 'navigation_%' AND timestamp > NOW() - INTERVAL '7 days') as avg_navigation,
        (SELECT ROUND(AVG(duration)::numeric, 2) FROM performance_metrics 
         WHERE label LIKE 'api_%' AND timestamp > NOW() - INTERVAL '7 days') as avg_api_calls,
        (SELECT jsonb_agg(jsonb_build_object('label', label, 'avg_duration', avg_duration)) 
         FROM (SELECT label, ROUND(AVG(duration)::numeric, 2) as avg_duration 
               FROM performance_metrics 
               WHERE timestamp > NOW() - INTERVAL '24 hours'
               GROUP BY label 
               HAVING AVG(duration) > 1000  -- Operations slower than 1 second
               ORDER BY avg_duration DESC LIMIT 10) t) as slow_operations,
        (SELECT jsonb_agg(jsonb_build_object(
            'date', date_trunc('day', timestamp)::date,
            'avg_duration', avg_duration
        ))
         FROM (SELECT 
                   date_trunc('day', timestamp) as day,
                   timestamp,
                   ROUND(AVG(duration)::numeric, 2) as avg_duration
               FROM performance_metrics 
               WHERE timestamp > NOW() - INTERVAL '30 days'
               GROUP BY date_trunc('day', timestamp), timestamp
               ORDER BY timestamp DESC) t) as performance_trends
$$;
