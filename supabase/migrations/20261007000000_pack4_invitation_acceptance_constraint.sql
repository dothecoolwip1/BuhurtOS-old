-- Accepting an invitation records the accepting account for auditability.
-- The original invitation constraint only allowed a null requester, making
-- private.accept_membership_invitation fail when it marked the request accepted.

alter table public.membership_requests
  drop constraint if exists membership_requests_check1;

alter table public.membership_requests
  add constraint membership_requests_request_kind_actor_check check (
    (request_kind='application'
      and requester_user_id is not null
      and invite_email is null
      and invite_token is null)
    or
    (request_kind='invitation'
      and invite_email is not null
      and invite_token is not null
      and expires_at is not null
      and (requester_user_id is null or status='accepted'))
  );
