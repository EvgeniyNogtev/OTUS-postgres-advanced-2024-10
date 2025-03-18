

DO
LANGUAGE plpgsql
$$
  DECLARE
    conf         record;
    rnd          int;
    device       text[]      = '{chrome, windows, linux, ios, android, mozilla, safari, aurora, macos}'::text[];
    gen_start    timestamptz = now() - INTERVAL '1 month';
    gen_finish   timestamptz = now();
    gen_interval interval    = '1 minute';
    gen_cnt      int         = 100000;
  BEGIN

---- users -------------------------------------------------------------------------------------------------------------
    INSERT INTO
      main.users(node_uid,
                 display_name,
                 local_id,
                 time_zone_id,
                 created_at,
                 deleted_at)
    WITH
      pre AS (SELECT
                t.dt,
                (random() * 100)::int       AS rnd,
                (random() * 100)::int       AS loc_ofset,
                ((random() * 100)::int * 4) AS tz_ofset
              FROM generate_series(gen_start, gen_finish, gen_interval) AS t(dt))
    SELECT
      CASE
        WHEN pre.rnd % 5 = 0
          THEN '33333333-3333-3333-3333-333333333333'::uuid
        WHEN pre.rnd % 2 = 0
          THEN '22222222-2222-2222-2222-222222222222'::uuid
        ELSE '11111111-1111-1111-1111-111111111111'::uuid
      END                            AS node_uid,
      md5((random() * 100000)::text) AS display_name,
      (SELECT
         id
       FROM main.locales
       LIMIT 1 OFFSET loc_ofset)     AS local_id,
      (SELECT
         id
       FROM main.time_zone
       LIMIT 1 OFFSET tz_ofset)      AS time_zonde_id,
      pre.dt,
      CASE
        WHEN pre.rnd % 3 = 0
          THEN pre.dt + INTERVAL '1 minute' * (random() * 1000000)
        ELSE NULL::timestamptz
      END                            AS deleted_at
    FROM pre
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'users end';

---- accounts ----------------------------------------------------------------------------------------------------------
    INSERT INTO
      main.accounts(node_uid,
                    provider_id,
                    login,
                    password,
                    user_uid,
                    payload,
                    created_at,
                    deleted_at)
    WITH
      usr  AS (SELECT
                 row_number() OVER (PARTITION BY u.node_uid) AS num,
                 u.uid,
                 u.node_uid
               FROM main.users u),
      cnt_user as (
        SELECT
          usr.node_uid,
          max(num) as max_node
        FROM usr
        GROUP BY usr.node_uid
      ),
      pre  AS (SELECT
                 (random() * 100)::int AS rnd
               FROM generate_series(1, gen_cnt) AS t(num)),
      pre2 AS (SELECT
                 pre.*,
                 CASE
                   WHEN pre.rnd % 5 = 0
                     THEN '33333333-3333-3333-3333-333333333333'::uuid
                   WHEN pre.rnd % 2 = 0
                     THEN '22222222-2222-2222-2222-222222222222'::uuid
                   ELSE '11111111-1111-1111-1111-111111111111'::uuid
                 END AS node_uid
               FROM pre),
      pre3 AS (
        SELECT pre2.*,
               random(1, (SELECT cnt_user.max_node::int
                          FROM cnt_user
                          WHERE cnt_user.node_uid = pre2.node_uid) ) user_random
        FROM pre2
          join cnt_user on cnt_user.node_uid = pre2.node_uid
      ),
      pre4 AS (SELECT
                 pre3.rnd,
                 pre3.node_uid,
                 (SELECT
                    id
                  FROM main.type_providers
                  LIMIT 1 OFFSET random(0, 5))                             AS providers_id,
                 substring((md5((random() * 100000)::text)) FROM 2 FOR 10) AS login,
                 substring((md5((random() * 100000)::text)) FROM 2 FOR 10) AS password,
                 (SELECT
                    uid
                  FROM usr
                  WHERE usr.num = pre3.user_random
                    AND usr.node_uid = pre3.node_uid
                  LIMIT 1)               AS user_uid
               FROM pre3)
    SELECT
      pre4.node_uid,
      pre4.providers_id,
      pre4.login,
      pre4.password,
      pre4.user_uid,
      jsonb_build_object(
        'user_uid', pre4.user_uid,
        'display_name', u.display_name,
        'account', jsonb_build_object(
          'login', pre4.login,
          'password', pre4.password,
          'providers', pre4.providers_id
          )
        )                                                    AS payload,
      u.created_at + INTERVAL '1 second' * (random() * 1000) AS created_at,
      CASE
        WHEN u.deleted_at IS NOT NULL
          THEN
          u.deleted_at + INTERVAL '1 second' * (random() * 100)
        ELSE
          CASE
            WHEN pre4.rnd % 3 = 0
              THEN u.created_at + INTERVAL '1 second' * (random() * 100000)
            ELSE NULL::timestamptz
          END
      END                                                    AS deleted_at
    FROM pre4
      INNER JOIN main.users u
        ON u.uid = pre4.user_uid
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'account end';

---- conference --------------------------------------------------------------------------------------------------------
    INSERT INTO
      main.conferences(node_uid,
                       start_at,
                       stop_at,
                       owner_uid,
                       display_name,
                       description)
    WITH
      usr  AS (SELECT
                 row_number() OVER (PARTITION BY u.node_uid) AS num,
                 u.uid,
                 u.node_uid
               FROM main.users u),
      cnt_user as (
        SELECT
          usr.node_uid,
          max(num) as max_node
        FROM usr
        GROUP BY usr.node_uid
      ),
      pre  AS (SELECT
                 t.dt,
                 (random() * 100)::int AS rnd
               FROM generate_series(gen_start, gen_finish, gen_interval) AS t(dt)),
      pre2 AS (SELECT
                 pre.dt,
                 pre.rnd,
                 CASE
                   WHEN pre.rnd % 5 = 0
                     THEN '33333333-3333-3333-3333-333333333333'::uuid
                   WHEN pre.rnd % 2 = 0
                     THEN '22222222-2222-2222-2222-222222222222'::uuid
                   ELSE '11111111-1111-1111-1111-111111111111'::uuid
                 END AS node_uid
               FROM pre),
      pre3 as (
        SELECT pre2.*,
               random(1, (SELECT cnt_user.max_node::int
                          FROM cnt_user
                          WHERE cnt_user.node_uid = pre2.node_uid) ) owner_random
        FROM pre2
          join cnt_user on cnt_user.node_uid = pre2.node_uid
      ),
      pre4 AS (SELECT
                 pre3.node_uid,
                 pre3.dt                                            AS start_at,
                 pre3.dt + INTERVAL '1 second' * (random() * 10000) AS stop_at,
                 (SELECT
                    usr.uid
                  FROM usr
                  WHERE usr.node_uid = pre3.node_uid
                    AND num = pre3.owner_random
                  LIMIT 1)                       AS owner_uid,
                 md5((random() * 100000)::text)                     AS display_name,
                 md5((random() * 10000000)::text)                   AS discription
               FROM pre3)
    SELECT
      pre4.node_uid,
      pre4.start_at,
      pre4.stop_at,
      pre4.owner_uid,
      pre4.display_name,
      pre4.discription
    FROM pre4;

    RAISE NOTICE 'conference end';

-- ----- participant ------------------------------------------------------------------------------------------------------
    FOR conf IN SELECT * FROM main.conferences ORDER BY node_uid
    LOOP
      rnd = random(1, 1000);
--
--     -- RAISE notice 'conf - %', conf.display_name;
      INSERT INTO
        main.participants(
          conference_uid,
          user_uid,
          user_node_uid,
          join_at,
          leave_at,
          device,
          node_uid
        )
      WITH
        usr AS (SELECT *,
                  to_timestamp(
                    random(
                      extract(EPOCH FROM conf.start_at),
                      extract(EPOCH FROM conf.stop_at)
                      )
                    ) AS dt1,
                  to_timestamp(
                    random(
                      extract(EPOCH FROM conf.start_at),
                      extract(EPOCH FROM conf.stop_at)
                      )
                    ) AS dt2
                FROM main.users
                WHERE users.created_at >= conf.start_at
                  AND users.created_at < conf.stop_at
                LIMIT rnd)
      SELECT
        conf.uid,
        usr.uid,
        usr.node_uid,
        CASE
          WHEN dt1 > dt2
            THEN dt2
          WHEN dt1 < dt2
            THEN dt1
          WHEN dt1 = dt2
            THEN dt1
        END AS joined,
        CASE
          WHEN dt1 > dt2
            THEN dt1
          WHEN dt1 < dt2
            THEN dt2
          WHEN dt1 = dt2
            THEN conf.stop_at
        END AS leave,
        device[random(1, array_length(device, 1))],
        conf.node_uid
      FROM usr;

     END LOOP;
-- ------------------------------------------------------------------------------------------------------------------------

    END;
$$;
