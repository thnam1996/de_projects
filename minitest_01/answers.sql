CREATE OR REPLACE FUNCTION generate_rls_condition(
    p_tablename TEXT,
    p_userid TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_condition   TEXT := '';
    v_field       TEXT;
    v_values      TEXT;
    v_in_list     TEXT[] := ARRAY[]::text[];
    v_likes       TEXT[] := ARRAY[]::text[];
    v_token       TEXT;
    v_field_pred  TEXT;
BEGIN
    IF EXISTS(
        SELECT 1
        FROM t_config_rls
        WHERE UserID=p_userid
        AND (TableName=p_tablename AND TableName='*'
            OR (TableName=p_tablename AND FieldName='*')
            OR ( TableName=p_tablename AND Value='*')
            )
    ) THEN
    RETURN  '1=1';
    END IF;

    FOR v_field IN
        (SELECT DISTINCT fieldname
         FROM t_config_rls
         WHERE userid = p_userid
           AND tablename = p_tablename
           AND fieldname IS NOT NULL
           AND fieldname <> '*'

         UNION

         SELECT DISTINCT fieldname
         FROM t_config_rls
         WHERE userid = p_userid
           AND TableName = '*'
           AND fieldname IS NOT NULL
           AND fieldname <> '*'
           AND LOWER(fieldname) in
               (SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name= lower(p_tablename)))
    LOOP
        SELECT string_agg(value, ',')
        INTO v_values
        FROM t_config_rls
        WHERE userid = p_userid
          AND (tablename = p_tablename OR tablename='*')
          AND fieldname = v_field
          AND value IS NOT NULL
          AND value <> '*';

        v_in_list := ARRAY[]::text[];
        v_likes   := ARRAY[]::text[];


        FOR v_token IN
            SELECT btrim(x)
                FROM unnest(string_to_array(v_values,',')) AS t(x)
        LOOP
            IF POSITION('%' IN v_token) > 0 THEN
                v_likes := v_likes || format('%s LIKE %L', v_field, v_token);


            ELSE
                v_in_list:=v_in_list || v_token;
            end if;
            end loop;

        v_field_pred := NULL;


        IF array_length(v_in_list,1) IS NOT NULL THEN
            v_field_pred := format(
                            '%s IN (%s)',
                            v_field,
                            array_to_string(
                                    ARRAY(SELECT quote_literal(btrim(x))
                                    FROM unnest(v_in_list) AS v(x)),','));
        end if;
        IF array_length(v_likes,1) IS NOT NULL THEN
            v_field_pred:='(' || array_to_string(v_likes,' OR ') || ')';
        end if;
        IF v_field_pred IS NOT NULL THEN
            IF v_condition ='' THEN
                v_condition := v_field_pred;
            ELSE
                v_condition:=v_condition || ' AND ' || v_field_pred;
            end if;
        end if;
        END loop;
    IF v_condition ='' THEN
    RETURN '1=0';
    END IF;

    RETURN v_condition;
END;
$$;