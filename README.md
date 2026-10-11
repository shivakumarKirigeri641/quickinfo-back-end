# quickinfo-back-end

Back end for **QuickInfo**, a SaaS platform for WhatsApp based and web based digital solutions, operated by ServerPe App Solutions.

It follows the structure of `serverpe-back-end` (Express 5, `pg`, encrypted JSON responses, in-memory rate limits) and **uses the same PostgreSQL database**.

## Shared database rules

- QuickInfo owns only tables prefixed `quickinfo_`.
- Its migrations are numbered from `200`, so they never collide with ServerPe (`001`–`010`) or ServerPe Chat (`100`).
- It reads the shared `contact_query_types` table for the contact form, and never alters it.
- Migrations are recorded in the shared `schema_migrations` table by filename.

| Table | Purpose |
| --- | --- |
| `quickinfo_services` | Solutions shown on the site and offered in the contact form |
| `quickinfo_privacy_policy` | Privacy Policy, one row per section |
| `quickinfo_terms_conditions` | Terms & Conditions, one row per section |
| `quickinfo_contact_queries` | Contact form leads, with policy-consent time and WhatsApp opt-in |

To change policy wording, `UPDATE` the row. The `updated_at` trigger moves the "Last updated" date shown on the site. Set `is_active = false` to hide a section.

## Setup

```bash
npm install
cp .env.example .env      # copy the PG* and MAIL* values from serverpe-back-end/.env
npm run migrate:check     # see what is pending
npm run migrate           # apply QuickInfo migrations
npm run dev               # nodemon, http://localhost:7788
```

`SECRET_KEY` must equal `VITE_SECRET_KEY` in `quickinfo-front-end/.env`.

## API

Every route is under `/api/quickinfo/platform/public`.

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/services` | Active solutions |
| GET | `/query-types` | Shared contact query types |
| GET | `/privacy-policy` | `{ last_updated, sections: [{ id, title, description }] }` |
| GET | `/terms-and-conditions` | Same shape as privacy policy |
| POST | `/contact-us` | Rate limited to 15 requests per 5 minutes per IP |

Contact body:

```json
{
  "user_name": "Asha",
  "mobile_number": "9876543210",
  "email": "optional@example.com",
  "business_name": "optional",
  "query_type_id": 1,
  "service_id": 2,
  "message": "10 to 1000 characters",
  "accept_policies": true,
  "whatsapp_opt_in": false
}
```

After saving, the API emails the visitor (if an email was given) and `ADMINMAIL` in the background. A WhatsApp acknowledgement is sent only when the visitor opted in **and** `QUICKINFO_WA_ACK_ENABLED=true`.

Responses are AES-256-CBC encrypted with a key derived from `SECRET_KEY`. That key also ships in the front-end bundle, so this hides payloads from casual inspection but is not a security boundary.
