-- MOSTIK v5.3.10: remove legacy admin demo-role state.
-- Active roles remain supported; demo mode is no longer used.
UPDATE sessions_auth SET demo_role = NULL WHERE demo_role IS NOT NULL;
