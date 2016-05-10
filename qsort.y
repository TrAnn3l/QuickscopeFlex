%{
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>
void yyerror(char *message);

  	typedef struct s_variablenlist
        {
                char variable[20];
                struct s_variablenlist *davor;
                struct s_variablenlist *danach;
        }variablenlist;

	typedef struct s_termlist
        {
                char term[10];
                struct s_variablenlist *varlist;
				struct s_variablenlist *firstvarlist;
                struct s_termlist *davor;
                struct s_termlist *danach;
        }termlist;

	typedef struct s_graphlist
        {
				int id;
                char typ[5];
				char eingang[100];
				char ausgang[100];
                struct s_graphlist *davor;
                struct s_graphlist *danach;
        }graphlist;

        termlist *momtermlist;
		termlist *firstmomterm;
		graphlist *momgraphlist;
		graphlist *firstgraphlist;

	int counter;
	int copies[50];
	int nextUpdate;
	int termCount;
	char iresult[100];
	char gresult[100];

void addVariable(char* vari) {
	strcpy(momtermlist->varlist->variable,vari);
	momtermlist->varlist->danach = (variablenlist*)malloc(sizeof(variablenlist));
	momtermlist->varlist->danach->davor = momtermlist->varlist;
	momtermlist->varlist = momtermlist->varlist->danach;
	momtermlist->varlist->danach=0;
}

void nextTerm() {
	momtermlist->danach = (termlist*)malloc(sizeof(termlist));
	momtermlist->danach->davor = momtermlist;
	momtermlist = momtermlist->danach;
	momtermlist->danach = 0;
	momtermlist->varlist = (variablenlist*)malloc(sizeof(variablenlist));
	momtermlist->firstvarlist = momtermlist->varlist;
	momtermlist->varlist->davor=0;
	momtermlist->varlist->danach=0;
}

void setTerm(char* term) {
	strcpy(momtermlist->term,term);
}

void nextGraph() {
	momgraphlist->danach = (graphlist*)malloc(sizeof(graphlist));
	momgraphlist->danach->davor = momgraphlist;
	momgraphlist = momgraphlist->danach;
	momgraphlist->danach=0;
	counter++;
}

void setGraphVal(char* typ,int id) {
	strcpy(momgraphlist->typ,typ);
	momgraphlist->id=id;
}

void setGraphIO(char* input,char* output) {
	strcpy(momgraphlist->eingang,input);
	strcpy(momgraphlist->ausgang,output);
}

void ausgabeAnalyse(){
	graphlist *dummy;

	dummy=firstgraphlist;
	while(dummy!=0){
		printf("%i %s %s %s\n", dummy->id, dummy->typ, dummy->ausgang, dummy->eingang);
		dummy=dummy->danach;
	}
}


bool gTest(int counter) {
	bool re = false;	
	char string[100];
	termlist *aktuellmomterm;
	termlist *savemomterm;
	variablenlist *firstvarlist;

	aktuellmomterm = momtermlist;
	firstvarlist=momtermlist->varlist;
	savemomterm=firstmomterm;

	for (int i=1;i<=counter;i++) {
		savemomterm=savemomterm->danach;
	}
	
	while (savemomterm->varlist->danach!=0){
		while (aktuellmomterm->varlist->danach!=0){	
			printf("VAR: %s:%s\n",aktuellmomterm->varlist->variable,savemomterm->varlist->variable);		
			if(strcmp(aktuellmomterm->varlist->variable,savemomterm->varlist->variable)==0)
			{
				printf("VAR: %s\n",aktuellmomterm->varlist->variable);
				if(re==false)
				{
					strcpy(gresult,aktuellmomterm->varlist->variable);
					re = true;	
				}else{
					sprintf(string,"%s,%s",gresult,aktuellmomterm->varlist->variable);
					strcpy(gresult,string);
				}
			}
			aktuellmomterm->varlist=aktuellmomterm->varlist->danach;
		}
		aktuellmomterm = momtermlist;
		aktuellmomterm->varlist=firstvarlist;
		savemomterm->varlist=savemomterm->varlist->danach;
	}
	return re;
}

bool iTest() {
	bool re=false;
	char string[100];
	termlist *aktuellmomterm;
	termlist *savemomterm;
	variablenlist *firstvarlist;

	aktuellmomterm = momtermlist;
	firstvarlist=momtermlist->varlist;
	savemomterm=firstmomterm;

	while (savemomterm->varlist!=0){
		while (aktuellmomterm->varlist!=0){
			if(strcmp(aktuellmomterm->varlist->variable,savemomterm->varlist->variable)==0)
			{
				if(re==false)
				{
					strcpy(iresult,aktuellmomterm->varlist->variable);	
					re = true;
				}else{
					sprintf(string,"%s %s",iresult,aktuellmomterm->varlist->variable);
					strcpy(iresult,string);
				}
			}
			aktuellmomterm->varlist=aktuellmomterm->varlist->danach;
		}
		aktuellmomterm = momtermlist;
		aktuellmomterm->varlist = firstvarlist;
		savemomterm->varlist=savemomterm->varlist->danach;
	}
	
	return re;
}

void updateOutputOfID(int id,int eingang) {
	graphlist *dummy;
	char string[100];

	dummy=firstgraphlist;
	
	while (dummy->id!=id) {
		dummy=dummy->danach;	
	}
	sprintf(string,"%s (%d,%d)",dummy->ausgang, counter, eingang);
	strcpy(dummy->ausgang,string);
}

void analyseTerm() {
	char string[50];
	int i=1;
	sprintf(string,"(%i,1)",counter+1);
	setGraphVal("U",counter);
	setGraphIO(momtermlist->term,string);
	//ausgabeAnalyse();
	//Testen ob 2. Element
	if (momtermlist->davor->davor==0) {
		nextGraph();
		setGraphVal("A",counter);
		sprintf(string,"(%i,1)",counter+1);
		setGraphIO("-",string);
		nextGraph();
		setGraphVal("C",counter);
		sprintf(string,"(%i,1)",counter+1);
		setGraphIO("-",string);
		//Save in array
		nextGraph();
		setGraphVal("U",counter);
		setGraphIO("-","-");
		updateOutputOfID(nextUpdate,2);
		nextUpdate=counter;
		//Update E
	//Testen ab 3. Element
	} else {
		// for schleife für ground test, von i=1 bis (<=) termCount
		//ausgabeAnalyse();
		for (i=1;i<=termCount;i++) {
			if (gTest(i)==true) {
				ausgabeAnalyse();
				//mach fancy shit
				if(iTest()==true){
					//beide Tests true
					nextGraph();
					setGraphVal("G",counter);
					sprintf(string,"(%i,2) (%i,1)",counter+2,counter+1);
					setGraphIO(gresult,string);
					nextGraph();
					setGraphVal("I",counter);
					sprintf(string,"(%i,2) (%i,1)", counter+1,counter+2);
					setGraphIO(iresult,string);
					nextGraph();
					setGraphVal("U",counter);
					sprintf(string,"(%i,1)",counter+1);
					setGraphIO("-",string);
				}else{
					//nur G true
					nextGraph();
					setGraphVal("G",counter);
					sprintf(string,"(%i,2) (%i,1)",counter+1,counter+2);
					setGraphIO(gresult,string);
					nextGraph();
					setGraphVal("U",counter);
					sprintf(string,"(%i,1)",counter+1);
					setGraphIO("-",string);
				}
			}else{
				if(iTest()==true){
					//nur i true
					nextGraph();
					setGraphVal("I",counter);
					sprintf(string,"(%i,2) (%i,1)", counter+2,counter+1);
					setGraphIO(iresult,string);
					nextGraph();
					setGraphVal("U",counter);
					sprintf(string,"(%i,1)",counter+1);
					setGraphIO("-",string);
				}else{
					//keins true
				}
			}			
		}
		//Testsende
		nextGraph();
		setGraphVal("A",counter);
		sprintf(string,"(%i,1)",counter+1);
		setGraphIO("-",string);
		nextGraph();
		setGraphVal("C",counter);
		sprintf(string,"(%i,1)",counter+1);
		setGraphIO("-",string);
		nextGraph();
		setGraphVal("U",counter);
		setGraphIO("-","");
		updateOutputOfID(nextUpdate,2);
		//Update E TODO
		nextUpdate=counter;
	}
}


void analyse() {
	if (momtermlist->danach==0) {
		setGraphVal("E",counter);
		setGraphIO("-","(2,1)");
		nextGraph();
		setGraphVal("R",counter);
		setGraphIO("-","-");
	} else {
		setGraphVal("E",counter);
		setGraphIO(momtermlist->term,"(2,1)");
		nextUpdate=counter;
		nextGraph();
		setGraphVal("C",counter);
		termCount=-1;
		while (momtermlist->danach!=0) {
			momtermlist=momtermlist->danach;
			termCount++;
			nextGraph();
			analyseTerm();
		}
	}
	//Ausgabe hier
	ausgabeAnalyse();
}

void ausgabe() {
	counter=1;
	if (momtermlist->davor==0){
	  //printf("%s",momtermlist->term);
	  while(momtermlist->varlist->davor!=0)
        {
            //printf("%s",momtermlist->varlist->variable);
			momtermlist->varlist=momtermlist->varlist->davor;
        }
		//printf("%s",momtermlist->varlist->variable);
	} else {
		while(momtermlist->davor!=0)
    	{
			//printf("%s",momtermlist->term);
			while(momtermlist->varlist->davor!=0)
        	{
            	//printf("%s",momtermlist->varlist->variable);
				momtermlist->varlist=momtermlist->varlist->davor;
        	}
			//printf("%s",momtermlist->varlist->variable);
			momtermlist->varlist=momtermlist->firstvarlist;
			momtermlist=momtermlist->davor;
		}
		//printf("%s",momtermlist->term);
		while(momtermlist->varlist->davor!=0)
        	{
            	//printf("%s",momtermlist->varlist->variable);
				momtermlist->varlist=momtermlist->varlist->davor;
        	}
			//printf("%s",momtermlist->varlist->variable);
	}

	momgraphlist = (graphlist*)malloc(sizeof(graphlist));
	momgraphlist->davor=0;
	firstgraphlist = momgraphlist;
	momtermlist =firstmomterm;
	momtermlist->varlist=momtermlist->firstvarlist;
	analyse();
}



%}

%start S

%union{
char character[100];
}

%token aus
%token bindestrich doppelpunkt gleich groesser kleiner groessergleich kleinergleich
%token klammerauf klammerzu eklammerauf eklammerzu
%token komma punkt oder 
%token leereliste variable term pipeliste kommaliste parameter

%type <character> term;
%type <character> variable;
%type <character> pipeliste;
%type <character> kommaliste;
%type <character> leereliste;
%type <character> gleich;
%type <character> kleiner;
%type <character> groessergleich;
%type <character> groesser;
%type <character> kleinergleich;

%%
S:  aus {
 printf("erkannt");
}
| Z 
| S Z | S aus {
}

Z: term { setTerm($1);} klammerauf A klammerzu C
   
A: leereliste {	addVariable($1);} B 
| pipeliste { addVariable($1);} B
| variable { addVariable($1);} B 

B: komma A | 

C: punkt aus { ausgabe();}
| doppelpunkt bindestrich D aus { ausgabe();}

D: G | variable {
	nextTerm();
	addVariable($1);
} E

E: kleiner variable 
{	
	setTerm($1);
	addVariable($2);
	
} F | groessergleich variable 
{	
	setTerm($1); 
	addVariable($2);
	
} F
F: komma {nextTerm();} Z 
G: term 
{
	nextTerm();
	setTerm($1);
} klammerauf A klammerzu H

H: punkt aus { ausgabe();}
| komma G

%%

int main(int argc, char **argv){
	momtermlist = (termlist*)malloc(sizeof(termlist));
	firstmomterm =momtermlist;
	momtermlist->davor = 0;
	momtermlist->danach = 0;
	momtermlist->varlist = (variablenlist*)malloc(sizeof(variablenlist));
	momtermlist->firstvarlist = momtermlist->varlist;
	momtermlist->varlist->davor=0;
	momtermlist->varlist->danach=0;
	yyparse();
	return 0;
}

void yyerror(char *message){
	printf("Good bye \n %s", message);
}
