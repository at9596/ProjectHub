# Authorization & User Roles

ProjectHub uses **Devise** for authentication and **Pundit** for authorization.

## User Roles

Every user belongs to an organization and is assigned one of the following roles:

| Role   | Description                                                                                       |
| ------ | ------------------------------------------------------------------------------------------------- |
| Owner  | Full access to the organization, projects, tasks, and user management.                            |
| Admin  | Can manage projects, tasks, and team members but cannot manage organization ownership or billing. |
| Member | Can work on assigned projects and tasks.                                                          |
| Viewer | Read-only access to projects and tasks.                                                           |

## Permissions Matrix

| Action                       | Owner | Admin | Member | Viewer |
| ---------------------------- | ----- | ----- | ------ | ------ |
| View Projects                | ✅     | ✅     | ✅      | ✅      |
| Create Projects              | ✅     | ✅     | ❌      | ❌      |
| Update Projects              | ✅     | ✅     | ❌      | ❌      |
| Delete Projects              | ✅     | ❌     | ❌      | ❌      |
| View Tasks                   | ✅     | ✅     | ✅      | ✅      |
| Create Tasks                 | ✅     | ✅     | ✅      | ❌      |
| Update Assigned Tasks        | ✅     | ✅     | ✅      | ❌      |
| Delete Tasks                 | ✅     | ✅     | ❌      | ❌      |
| Invite Users                 | ✅     | ✅     | ❌      | ❌      |
| Change User Roles            | ✅     | ❌     | ❌      | ❌      |
| Manage Organization Settings | ✅     | ❌     | ❌      | ❌      |

## Authorization Implementation

Authorization is implemented using Pundit policies.

### Project Policy

* Owners and Admins can create and update projects.
* Only Owners can delete projects.
* All authenticated users can view projects within their organization.

### Task Policy

* Owners and Admins have full task management access.
* Members can create tasks and update tasks assigned to them.
* Viewers have read-only access.

## Multi-Tenant Security

ProjectHub is a multi-tenant application.

Users can only access resources that belong to their organization.

Example:

Organization A users cannot access:

* Projects from Organization B
* Tasks from Organization B
* Users from Organization B

This is enforced through Pundit scopes and database-level associations.

## Example User Role Enum

```ruby
enum :role, {
  owner: 0,
  admin: 1,
  member: 2,
  viewer: 3
}
```

## Security Notes

* Authentication is handled by Devise.
* Authorization is handled by Pundit.
* Every controller action requiring access control must call `authorize`.
* Collection queries must use `policy_scope`.
* Unauthorized actions raise `Pundit::NotAuthorizedError`.
