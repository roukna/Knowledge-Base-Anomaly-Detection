RawLayout := record
string rawTxt;
end;

fileRaw := dataset('~thor::main.txt', RawLayout, CSV(heading(0),separator(''),quote('')));

pattern identifier := pattern('REVISION');
pattern whitespace := pattern('[ \t\r\n]');
pattern numFmt := pattern('[0-9]')+;
pattern alphaFmt := pattern('[A-Za-z-_:.]')+;
pattern hoursFromGMT := pattern('[\\-\\+]') numFmt;
pattern yearFmt := numFmt;
pattern monthFmt := numFmt;
pattern dayFmt := numFmt;
pattern hoursFmt := numFmt;
pattern minutesFmt := numFmt;
pattern secondsFmt := numFmt;
pattern dateFmt := yearFmt '-' monthFmt '-' dayFmt 'T' hoursFmt ':' minutesFmt ':' secondsFmt 'Z';

pattern line := identifier whitespace numFmt whitespace numFmt whitespace alphaFmt whitespace dateFmt whitespace alphaFmt whitespace numFmt;

//Input record layout for the extracted data 
LogLayout := RECORD
   STRING revision_iden := MATCHTEXT(identifier);
   STRING article_id := MATCHTEXT(numFmt);
   STRING rev_id := MATCHTEXT(numFmt);
   STRING article_title := MATCHTEXT(alphaFmt);
   STRING timestamp := MATCHTEXT(dateFmt);
   STRING username := MATCHTEXT(alphaFmt);
   STRING user_id := MATCHTEXT(numFmt);
end;

//Parse the file 
logFile := PARSE(fileRaw,
                 rawTxt,
                 line,
                 LogLayout,first);
 
TrashLayout := RECORD
  STRING t := fileRaw.rawTxt;
end;
  
trashFile := PARSE(fileRaw,
           rawTxt,
           line,
           TrashLayout,NOT MATCHED ONLY);
                                 
OUTPUT(logFile);                                                          
OUTPUT(trashFile);