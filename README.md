# Cropio Test Task

A Rails application for managing fields with geographical data. The application uses PostgreSQL with PostGIS for storing geospatial data and provides an API for working with fields.

## System Requirements

- Ruby 3.2.3
- PostgreSQL 16 with PostGIS 3.4
- Docker and Docker Compose (for easy setup)
- Node.js (for asset pipeline)

## Quick Start with Docker

The easiest way to run the project:

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd cropio_test_task
   ```

2. **Run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

3. **Open your browser:**
   ```
   http://localhost:3000
   ```

Docker Compose will automatically:
- Start PostgreSQL with PostGIS
- Install Ruby dependencies
- Run database migrations
- Start the Rails server

## Testing

```bash
bundle exec rspec
```

## API Endpoints

### Fields

- `GET /fields` - list all fields
- `GET /fields/:id` - get field details
- `POST /fields` - create new field
- `PUT /fields/:id` - update field
- `DELETE /fields/:id` - delete field

### Example field creation:

```json
POST /fields
{
  "field": {
    "name": "Field 1",
    "area": 100.5,
    "coordinates": {
      "type": "Polygon",
      "coordinates": [[[30.0, 50.0], [30.1, 50.0], [30.1, 50.1], [30.0, 50.1], [30.0, 50.0]]]
    }
  }
}
```

