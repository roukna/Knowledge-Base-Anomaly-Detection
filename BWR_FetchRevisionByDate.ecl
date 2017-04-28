IMPORT WikiRev;
IMPORT STD;

DtForm := RECORD
	STRING8 dt;
END;

SetNames := STD.Str.SplitWords(WikiRev.AllDates,',');
//AllDates := Dataset(SetNames,DtForm);
AllDates := Dataset(['20030511','20020225'],DtForm);
OUTPUT(AllDates);
RevRecords := WikiRev.File_WikiProcessed;

getEntropy(STRING8 dateFilter) := FUNCTION

	OutputEntropy := RECORD
	DECIMAL5_5 Entropy;
	END;

	FetchRevisionByDate :=
	FETCH(WikiRev.File_WikiProcessed,
    	  WikiRev.IDX_RevisionByDate(Dt = dateFilter),
      		RIGHT.fpos);

	GrForm := RECORD
		DECIMAL5_5 Entropy := -(COUNT(GROUP)/COUNT(FetchRevisionByDate))*LOG(COUNT(GROUP)/COUNT(FetchRevisionByDate));
	END;
  
	OutputEntropy calculateEntropy(GrForm PrevInputRec, GrForm CurrInputRec) :=TRANSFORM
	
		SELF.Entropy := PrevInputRec.Entropy + CurrInputRec.Entropy;
		
	END;

	
	NewTable2 := TABLE(FetchRevisionByDate, GrForm, ArticleId);
	
	//IMPROVEMENT --- CHANGE TO SUM
	ProcessedDataset := ITERATE(NewTable2, calculateEntropy(LEFT, RIGHT));

	
	opval:= if((COUNT(FetchRevisionByDate) > 0), MAX(ProcessedDataset, ProcessedDataset.Entropy), 0);
	//opval:= if((INTEGER8)dateFilter % 2 > 0 , 1, 0);
	RETURN opval;

END;

/*dedupDate :=  DEDUP(RevRecords, RevRecords.Dt);

DateFrm := RECORD
STRING8 dt := dedupDate.dt;
END;

WikiRev.EntropyLayout findEntropyforDate(DateFrm inputRec) := TRANSFORM

	SELF.Entropy := getEntropy(inputRec.dt);
END;*/



startDate := (INTEGER) MIN(RevRecords, RevRecords.Dt);
endDate := (INTEGER) MAX(RevRecords, RevRecords.Dt);

DECIMAL5_5 E := 0.24421;
DECIMAL5_5 T := 0.014; 
INTEGER5 anacount := 0 : STORED('anacount');
DECIMAL5_5 dailyentropy := 0 : STORED('dailyEntropy');
#STORED('myname',0);
#STORED('dailyEntropy',0);
noOfDays := STD.Date.DaysBetween(startDate, endDate);

	AllEntropy := RECORD
		STRING8 Dt;
		STRING Entropy;
	END;

//DateSetLayout := TABLE(AllDates, DtForm);

AllEntropy combineEntropyDate(DtForm inputDate) 

	:= TRANSFORM

	SELF.Dt := inputDate.dt;
	SELF.Entropy := (STRING)getEntropy(inputDate.dt);
END ;

ProcessedDataset := PROJECT(AllDates,combineEntropyDate(LEFT));

output(ProcessedDataset);


//OUTPUT(RevRecords);


//OUTPUT(LOOP(namesTable2, 4, ROWS(LEFT) & ROWS(LEFT)));*/

/*dateSet := TABLE(dedupDate, DateFrm, dt);

ProcessedDataset := PROJECT(dateSet, findEntropyforDate(LEFT));

output(ProcessedDataset);*/