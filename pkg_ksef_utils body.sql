create or replace PACKAGE body pkg_ksef_utils IS

FUNCTION gen_ksef_tech_part (
    p_len IN PLS_INTEGER DEFAULT 12
) RETURN VARCHAR2 IS
    l_res  VARCHAR2(100);
BEGIN
    IF p_len IS NULL OR p_len <= 0 THEN
        raise_application_error(
            -20001,
            'pkg_ksef_utils.gen_ksef_tech_part: p_len must be > 0'
        );
    END IF;

    -- X = litery + cyfry (DBMS_RANDOM)
    l_res := dbms_random.string('x', p_len);
    RETURN l_res;
END gen_ksef_tech_part;


FUNCTION gen_ksef_checksum (
    p_nip  IN VARCHAR2,
    p_date IN DATE,
    p_tech IN VARCHAR2
) RETURN VARCHAR2 IS
    l_str VARCHAR2(100);
    l_sum PLS_INTEGER := 0;
    l_ch  CHAR(1);
    l_val PLS_INTEGER;
BEGIN
    -- konkatenacja: NIP (tylko cyfry) + data + część techniczna
    l_str :=
        regexp_replace(p_nip, '[^0-9]') ||
        to_char(p_date, 'YYYYMMDD') ||
        p_tech;

    -- prosty algorytm testowy:
    -- wagi 1,3,1,3,..., na końcu modulo 100
    FOR i IN 1 .. length(l_str) LOOP
        l_ch := substr(l_str, i, 1);

        IF l_ch BETWEEN '0' AND '9' THEN
            l_val := TO_NUMBER(l_ch);
        ELSIF l_ch BETWEEN 'a' AND 'z' THEN
            l_val := ascii(l_ch) - ascii('a') + 10; -- A=10..
        ELSIF l_ch BETWEEN 'a' AND 'z' THEN
            l_val := ascii(l_ch) - ascii('a') + 10;
        ELSE
            l_val := 0;
        END IF;

        IF MOD(i, 2) = 1 THEN
            l_sum := l_sum + l_val;        -- waga 1
        ELSE
            l_sum := l_sum + 3 * l_val;    -- waga 3
        END IF;
    END LOOP;

    l_val := MOD(100 - mod(l_sum, 100), 100); -- 0..99
    RETURN lpad(l_val, 2, '0');
END gen_ksef_checksum;


FUNCTION gen_ksef_number (
    p_nip  IN VARCHAR2,
    p_date IN DATE DEFAULT trunc(sysdate)
) RETURN VARCHAR2 IS
    l_nip_clean VARCHAR2(20);
    l_tech      VARCHAR2(12);
    l_chk       VARCHAR2(2);
BEGIN
    IF p_nip IS NULL THEN
        raise_application_error(
            -20002,
            'pkg_ksef_utils.gen_ksef_number: p_nip is required'
        );
    END IF;

    l_nip_clean := regexp_replace(p_nip, '[^0-9]');

    IF l_nip_clean IS NULL THEN
        raise_application_error(
            -20003,
            'pkg_ksef_utils.gen_ksef_number: p_nip must contain digits'
        );
    END IF;

    l_tech := gen_ksef_tech_part(12);
    l_chk  := gen_ksef_checksum(l_nip_clean, p_date, l_tech);

    RETURN l_nip_clean
           || '-' || to_char(p_date, 'YYYYMMDD')
           || '-' || l_tech
           || '-' || l_chk;
END gen_ksef_number;

END;
/
