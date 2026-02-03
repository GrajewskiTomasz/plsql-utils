create or replace PACKAGE pkg_ksef_utils IS

FUNCTION gen_ksef_number (
    p_nip  IN VARCHAR2,
    p_date IN DATE DEFAULT trunc(SYSDATE)
) return VARCHAR2;

FUNCTION gen_ksef_checksum (
    p_nip  IN VARCHAR2,
    p_date IN DATE,
    p_tech IN VARCHAR2
) return VARCHAR2;

FUNCTION gen_ksef_tech_part (
    p_len IN pls_integer DEFAULT 12
) return VARCHAR2;

END;
/
