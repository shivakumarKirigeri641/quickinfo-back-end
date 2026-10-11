-- 202_quickinfo_policy_contacts.sql — fill the grievance officer, support
-- email and jurisdiction placeholders left by 201.
--
-- replace() only touches rows that still hold a placeholder, so running this
-- after the text has been edited by hand changes nothing.

BEGIN;

UPDATE quickinfo_privacy_policy
   SET description = replace(replace(description,
         '[NAME]', 'Shivakumar K'),
         '[GRIEVANCE EMAIL]', 'support@quickinfo.in')
 WHERE description LIKE '%[NAME]%' OR description LIKE '%[GRIEVANCE EMAIL]%';

UPDATE quickinfo_terms_conditions
   SET description = replace(description, '[CITY]', 'Bangalore')
 WHERE description LIKE '%[CITY]%';

UPDATE quickinfo_terms_conditions
   SET description = 'For questions about these Terms, contact us through the Contact Us page on this website or email support@quickinfo.in.'
 WHERE title = 'Contact Us'
   AND description = 'For questions about these Terms, contact us through the Contact Us page on this website.';

COMMIT;
