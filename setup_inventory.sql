-- Enable the pg_graphql extension if not already enabled (optional but usually present in Supabase)
-- create extension if not exists pg_graphql;

-------------------------------------------------------------------------------
-- 1. Project Materials (Master Inventory)
-------------------------------------------------------------------------------
-- Stores the current state of every item on a specific project.
-- Includes a CHECK constraint to ensure quantity never drops below zero.

create table if not exists project_materials (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade not null,
  name text not null,
  unit text not null, -- LOCKED (e.g., "Tons"). Cannot be edited once created.
  current_quantity numeric not null default 0 check (current_quantity >= 0),
  created_at timestamptz default now() not null
);

-- RLS Policies for project_materials
alter table project_materials enable row level security;

-- Allow read access to project members
create policy "Members can view materials"
  on project_materials for select
  using (
    exists (
      select 1 from members
      where members.project_id = project_materials.project_id
      and members.user_id = auth.uid()
      and members.is_accepted = true
    )
  );

-- Allow project admins to insert/update materials
create policy "Admins can manage materials"
  on project_materials for all
  using (
    exists (
      select 1 from members
      where members.project_id = project_materials.project_id
      and members.user_id = auth.uid()
      and members.is_admin = true
    )
  );

-------------------------------------------------------------------------------
-- 2. Material Transactions (Audit Trail)
-------------------------------------------------------------------------------
-- A history of every single change to the stock.
-- Strict 'IN' and 'OUT' enum types.

create type transaction_type as enum ('IN', 'OUT');

create table if not exists material_transactions (
  id uuid primary key default gen_random_uuid(),
  material_id uuid references project_materials(id) on delete cascade not null,
  type transaction_type not null,
  quantity_change numeric not null, -- The absolute amount changed
  daily_log_id uuid references daily_logs(id) on delete set null, -- Nullable if Restock
  actor_id uuid references auth.users(id) on delete set null, -- Who made the change
  timestamp timestamptz default now() not null
);

-- RLS Policies for material_transactions
alter table material_transactions enable row level security;

-- Allow read access to project members (Audit trail visibility)
create policy "Members can view transactions"
  on material_transactions for select
  using (
    exists (
      select 1 from project_materials
      join members on members.project_id = project_materials.project_id
      where project_materials.id = material_transactions.material_id
      and members.user_id = auth.uid()
      and members.is_accepted = true
    )
  );

-- Allow writes (logic will be enforced by app/Edge Functions, but basic policy needed)
create policy "Members can insert transactions"
  on material_transactions for insert
  with check (
    exists (
      select 1 from project_materials
      join members on members.project_id = project_materials.project_id
      where project_materials.id = material_transactions.material_id
      and members.user_id = auth.uid()
      and members.is_accepted = true
    )
  );

-------------------------------------------------------------------------------
-- 3. Database Functions (Strict Logic)
-------------------------------------------------------------------------------
-- RPC function to handle transactions atomically.

create or replace function record_material_transaction(
  p_material_id uuid,
  p_quantity_change numeric,
  p_transaction_type transaction_type,
  p_daily_log_id uuid,
  p_actor_id uuid
)
returns void
language plpgsql
as $$
declare
  v_new_quantity numeric;
begin
  -- 1. Perform the update on project_materials
  -- The CHECK (current_quantity >= 0) constraint on the table will AUTOMATICALLY 
  -- raise an exception if v_new_quantity < 0.
  
  update project_materials
  set current_quantity = case 
      when p_transaction_type = 'IN' then current_quantity + p_quantity_change
      when p_transaction_type = 'OUT' then current_quantity - p_quantity_change
    end
  where id = p_material_id
  returning current_quantity into v_new_quantity;
  
  if not found then
    raise exception 'Material not found';
  end if;

  -- 2. Insert the audit record
  insert into material_transactions (
    material_id,
    type,
    quantity_change,
    daily_log_id,
    actor_id,
    timestamp
  ) values (
    p_material_id,
    p_transaction_type,
    p_quantity_change,
    p_daily_log_id,
    p_actor_id,
    now()
  );

end;
$$;
