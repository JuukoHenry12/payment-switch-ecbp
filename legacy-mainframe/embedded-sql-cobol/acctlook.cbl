       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTLOOK.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  SQLDA-ID pic 9(4) comp-5.
       01  SQLDSIZE pic 9(4) comp-5.
       01  SQL-STMT-ID pic 9(4) comp-5.
       01  SQLVAR-INDEX pic 9(4) comp-5.
       01  SQL-DATA-TYPE pic 9(4) comp-5.
       01  SQL-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-LITERAL pic X(258).
       01  SQL-LITERAL1 pic X(130).
       01  SQL-LITERAL2 pic X(130).
       01  SQL-LITERAL3 pic X(130).
       01  SQL-LITERAL4 pic X(130).
       01  SQL-LITERAL5 pic X(130).
       01  SQL-LITERAL6 pic X(130).
       01  SQL-LITERAL7 pic X(130).
       01  SQL-LITERAL8 pic X(130).
       01  SQL-LITERAL9 pic X(130).
       01  SQL-LITERAL10 pic X(130).
       01  SQL-IS-LITERAL pic 9(4) comp-5 value 1.
       01  SQL-IS-INPUT-HVAR pic 9(4) comp-5 value 2.
       01  SQL-CALL-TYPE pic 9(4) comp-5.
       01  SQL-SECTIONUMBER pic 9(4) comp-5.
       01  SQL-INPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-OUTPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-VERSION-NUMBER pic 9(4) comp-5.
       01  SQL-ARRAY-SIZE pic 9(4) comp-5.
       01  SQL-IS-STRUCT  pic 9(4) comp-5.
       01  SQL-IS-IND-STRUCT pic 9(4) comp-5.
       01  SQL-STRUCT-SIZE pic 9(4) comp-5.
       01  SQLA-PROGRAM-ID.
           05 SQL-PART1 pic 9(4) COMP-5 value 172.
           05 SQL-PART2 pic X(6) value "AEAWAI".
           05 SQL-PART3 pic X(24) value "EBKAJGIq01111 2         ".
           05 SQL-PART4 pic 9(4) COMP-5 value 8.
           05 SQL-PART5 pic X(8) value "DB2INST1".
           05 SQL-PART6 pic X(120) value LOW-VALUES.
           05 SQL-PART7 pic 9(4) COMP-5 value 8.
           05 SQL-PART8 pic X(8) value "ACCTLOOK".
           05 SQL-PART9 pic X(120) value LOW-VALUES.
                               
           
      *EXEC SQL INCLUDE SQLCA END-EXEC
      * SQL Communication Area - SQLCA
       COPY 'sqlca.cbl'.

                                           

           
      *EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  WS-ACCT-ID          PIC X(10).
       01  WS-TIMESTAMP        PIC X(26).
       01  WS-BALANCE          PIC S9(9)V99 COMP-3.
           
      *EXEC SQL END DECLARE SECTION END-EXEC
                                                 

       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE "ACC0001234" TO WS-ACCT-ID

           
      *EXEC SQL 
      *SELECT CHAR(CURRENT TIMESTAMP)
      *           INTO :WS-TIMESTAMP
      *           FROM SYSIBM.SYSDUMMY1
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 1 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 26 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-TIMESTAMP
            BY VALUE 0
                     0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                                        

           DISPLAY "SQLCODE: " SQLCODE
           DISPLAY "Result : " WS-TIMESTAMP

           STOP RUN.
