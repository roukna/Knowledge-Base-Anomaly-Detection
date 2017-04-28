IMPORT WikiRev;
EXPORT IDX_RevisionByDate :=
INDEX(WikiRev.File_WikiProcessed, {Dt,fpos}, '~thor::RevisionByDateINDEX');