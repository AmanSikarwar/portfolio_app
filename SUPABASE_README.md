# Portfolio App with Supabase Integration

A Flutter portfolio web application with dynamic content management through Supabase backend integration.

## Features

- **Dynamic Content Management**: Resume data (experiences, skills, projects, personal info) fetched from Supabase database
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Modern UI**: Beautiful animations and smooth transitions
- **Fallback Support**: Works with hardcoded data if Supabase is not configured
- **Real-time Updates**: Content can be updated in Supabase and reflects immediately
- **Image Storage**: Support for profile images and project screenshots via Supabase Storage

## Tech Stack

- **Frontend**: Flutter Web, Provider for state management
- **Backend**: Supabase (PostgreSQL database + Storage)
- **Deployment**: Can be deployed to any web hosting service

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd portfolio_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup (Optional)

If you want to use dynamic content management:

#### A. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

#### B. Set up the Database

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Run the SQL schema from `supabase_schema.sql` file in your project
4. This will create all necessary tables, indexes, and sample data

#### C. Configure Storage (Optional)

1. Go to Storage in your Supabase dashboard
2. Create a new bucket called `portfolio-assets`
3. Set it to public for direct image access
4. Upload your profile image and project screenshots

#### D. Environment Configuration

1. Copy the `.env` file in your project root
2. Update the values with your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Run the Application

```bash
flutter run -d chrome
```

## Supabase Database Schema

The application uses the following main tables:

### `personal_info`

- Stores personal information (name, title, about me, contact details)
- Contains social media links and resume URL
- Stores an array of roles for the rotating text display

### `experiences`

- Work experience entries
- Includes company, role, duration, responsibilities
- Skills array for each experience
- Sort order for display sequence

### `skills`

- Technical skills with proficiency levels
- Categorized (e.g., "Programming Languages", "Web Development")
- Icon names for visual representation
- Sort order for display sequence

### `projects`

- Portfolio projects with descriptions
- GitHub and live URLs
- Technology stack arrays
- Featured flag for highlighting important projects
- Image URLs for project screenshots

## Customization

### Adding New Content

1. **Personal Info**: Update the `personal_info` table with your details
2. **Experiences**: Add entries to the `experiences` table
3. **Skills**: Add your skills to the `skills` table with appropriate categories
4. **Projects**: Add your projects to the `projects` table

### Uploading Images

1. Upload images to the `portfolio-assets` bucket in Supabase Storage
2. Update the `profile_image_url` in `personal_info` table
3. Update `image_url` in `projects` table for project images

### Fallback Mode

If Supabase is not configured, the app will use hardcoded fallback data defined in `PortfolioDataProvider.loadFallbackData()`. You can customize this data directly in the code.

## Deployment

### Web Deployment

1. Build the web app:

```bash
flutter build web
```

2. Deploy the `build/web` folder to your hosting service (Netlify, Vercel, Firebase Hosting, etc.)

### Environment Variables for Production

For production deployment, set environment variables in your hosting platform:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anon key

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart          # Supabase configuration
│   ├── providers/
│   │   ├── portfolio_data_provider.dart   # Main data provider
│   │   └── theme_provider.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/                           # Data models
│   │   ├── personal_info.dart
│   │   ├── experience.dart
│   │   ├── skill.dart
│   │   └── project.dart
│   └── services/
│       ├── supabase_service.dart         # Supabase API service
│       └── github_service.dart
├── presentation/
│   ├── pages/
│   │   └── portfolio_page.dart
│   └── widgets/
└── widgets/                              # UI components
    ├── home_section.dart
    ├── about_section.dart
    ├── experience_section.dart
    ├── projects_section.dart
    └── contact_section.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you encounter any issues or have questions, please create an issue in the repository or contact [your-email@example.com].

---

**Note**: This portfolio app is designed to be easily customizable. You can modify the UI components, add new sections, or integrate with different backends as needed.
