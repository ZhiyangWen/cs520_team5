drop extension if exists "pg_net";


  create table "public"."dietary_profiles" (
    "user_id" uuid not null,
    "max_calories" integer,
    "min_protein" integer,
    "allergies" text[]
      );


alter table "public"."dietary_profiles" enable row level security;


  create table "public"."meals" (
    "meal_name" text[],
    "dining_hall" text[],
    "calories" integer,
    "protein" integer,
    "ingredients" text[]
      );


CREATE UNIQUE INDEX dietary_profiles_pkey ON public.dietary_profiles USING btree (user_id);

alter table "public"."dietary_profiles" add constraint "dietary_profiles_pkey" PRIMARY KEY using index "dietary_profiles_pkey";

alter table "public"."dietary_profiles" add constraint "dietary_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."dietary_profiles" validate constraint "dietary_profiles_user_id_fkey";

grant delete on table "public"."dietary_profiles" to "anon";

grant insert on table "public"."dietary_profiles" to "anon";

grant references on table "public"."dietary_profiles" to "anon";

grant select on table "public"."dietary_profiles" to "anon";

grant trigger on table "public"."dietary_profiles" to "anon";

grant truncate on table "public"."dietary_profiles" to "anon";

grant update on table "public"."dietary_profiles" to "anon";

grant delete on table "public"."dietary_profiles" to "authenticated";

grant insert on table "public"."dietary_profiles" to "authenticated";

grant references on table "public"."dietary_profiles" to "authenticated";

grant select on table "public"."dietary_profiles" to "authenticated";

grant trigger on table "public"."dietary_profiles" to "authenticated";

grant truncate on table "public"."dietary_profiles" to "authenticated";

grant update on table "public"."dietary_profiles" to "authenticated";

grant delete on table "public"."dietary_profiles" to "service_role";

grant insert on table "public"."dietary_profiles" to "service_role";

grant references on table "public"."dietary_profiles" to "service_role";

grant select on table "public"."dietary_profiles" to "service_role";

grant trigger on table "public"."dietary_profiles" to "service_role";

grant truncate on table "public"."dietary_profiles" to "service_role";

grant update on table "public"."dietary_profiles" to "service_role";

grant delete on table "public"."meals" to "anon";

grant insert on table "public"."meals" to "anon";

grant references on table "public"."meals" to "anon";

grant select on table "public"."meals" to "anon";

grant trigger on table "public"."meals" to "anon";

grant truncate on table "public"."meals" to "anon";

grant update on table "public"."meals" to "anon";

grant delete on table "public"."meals" to "authenticated";

grant insert on table "public"."meals" to "authenticated";

grant references on table "public"."meals" to "authenticated";

grant select on table "public"."meals" to "authenticated";

grant trigger on table "public"."meals" to "authenticated";

grant truncate on table "public"."meals" to "authenticated";

grant update on table "public"."meals" to "authenticated";

grant delete on table "public"."meals" to "service_role";

grant insert on table "public"."meals" to "service_role";

grant references on table "public"."meals" to "service_role";

grant select on table "public"."meals" to "service_role";

grant trigger on table "public"."meals" to "service_role";

grant truncate on table "public"."meals" to "service_role";

grant update on table "public"."meals" to "service_role";


  create policy "User access to dietary_profiles"
  on "public"."dietary_profiles"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));



