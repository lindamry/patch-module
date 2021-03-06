A1AEM	;ISC-Albany/pke-called entries for mailing patches ;01/10/2007
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
DD	;
	I $D(X),X="db",$P(^A1AE(11005,D0,0),"^",3)'=999 W !?3,"The 'DATABASE' category is only for DBA patches." K X Q
	I $D(X),"Ee"[$E(X_1),"em"'[$E($P(^A1AE(11005,D0,0),"^",7)_1) W !?3,"The 'ENHANCEMENT' category must have PRIORITY of EMERGENCY or MANDATORY." K X Q
	Q
	;I $D(X),"PApp"[$E(X_1,1,2),"em"'[$E($P(^A1AE(11005,D0,0),"^",7)_1) W !?3,"The 'PATCH FOR A PATCH' category must have PRIORITY of EMERGENCY or MANDATORY." K X Q
	Q
CREC	D NOW^%DTC I $D(^A1AE(11005.1,DA,0)) S $P(^(0),U,4,5)=AXMZ_"^"_%
	K %
	Q
VREC	D NOW^%DTC I $D(^A1AE(11005.1,DA,0)) S $P(^(0),U,6,7)=AXMZ_"^"_%
	K %
	Q
CONT	S SAVX=X
	W !?2,"This patch has already been 'Completed', editing will change "
	S A1AERD("A")="  the status back to 'UNDER DEVELOPMENT' continue ? "
	S A1AERD(1)="Yes^continue editing with status as 'UNDER DEVELOPMENT'"
	S A1AERD(2)="No^quit and keep the status as 'COMPLETE/NOT RELEASED'"
	S A1AERD(0)="S"
	S A1AERD("B")=2 D ^A1AERD K A1AERD I X'["Y" S Y=""
	S X=SAVX
	Q
	;
TRASH	;Remove old message from queue
	Q:'$D(AXMZ)
	N QUE,XMDUZ,X
	D QUE I $D(QUE),QUE S (XMKD,XMK)=QUE,XMZ=AXMZ,XMDUZ=.5 D KLQ
	K AXMDUZ,XMKD,XMK,XMZ,XMDI
	Q
KLQ	;
	S X="XMA1B" X ^%ZOSF("TEST") I $T D KLQ^XMA1B Q
	D KLQ^XMA1 Q
	;
TRASHALL(AXMZ)	;Remove other entries in QUE with same start
	N XMKD,XMK,XMZ,XMDUZ,DA,X1,XMSUB
	S XMSUB=$P($G(^XMB(3.9,AXMZ,0)),U) Q:'$L(XMSUB)
	S XMSUB=$P(XMSUB," "),DA=0
	F  S DA=$O(^XMB(3.7,.5,2,QUE,1,DA)) Q:'DA  S X=^(DA,0) D
	. S XMZ=+X,X=$G(^XMB(3.9,XMZ,0)),X1=$P($P(X,U)," ")
	. I XMSUB=X1 D
	. . N XMKD,XMK S (XMKD,XMK)=QUE,XMDUZ=.5 D KLQ
	Q 
	;
XM	I '$D(XMDUZ) S XMDUZ=DUZ
	S XMDUN=$P(^VA(200,XMDUZ,0),U),(XMKN,XMLOCK)="",(XMK,XMZ)=0
	Q
	;
AGN	R !?3,"Enter Subject: ",X:DTIME Q:X=""!(X["^")  I X?1"R"1N.N!($L(X)>64)!($L(X)<3) W *7 W:X["?" "      Use namespace*version anything 'AAAA*n.nn ....'" G AGN
	S XMSUB=X K ^UTILITY($J) X ^%ZOSF("RSEL")
	S AZ="" F I=0:0 S AZ=$O(^UTILITY($J,AZ)) Q:AZ=""  S XMROU(AZ)=""
	I $D(XMROU)<10 W !?3,"No routines selected" H 2 Q
	S XMTEXT="X(",X(1)=""
	S XMY(XMDUN_"@Q-PATCH.VA.GOV")=""
	D ^XMD W !?3,"message queued to 'Q-PATCH.VA.GOV' "
	Q
	;
PACK	;Build a packman message
	D XM,AGN G QPK
	;
QPK	D KILL^XM K AZ,XMROU,^UTILITY($J)
	Q
	;
MMM	;ov x=val domain, "",x9
	S DIC="^DIC(4.2,",DIC(0)="",X9="" F Y=0:0 D ^DIC Q:Y>0  S X9=X9_$S($L(X9):".",1:"")_$P(X,"."),X=$P(X,".",2,999) I X="" W !,*7,"Domain not found." Q
	Q
DOMAIN	;out xxmy("user or group @ domain")
	;
	;
	;Send to the NETWORK ROUTING list in the 11007 file for A1AE package.
VER	K XMY,AXMY S AN=$O(^DIC(9.4,"C","A1AE",0)) Q:'AN
	F AZ=0:0 S AZ=$O(^A1AE(11007,AN,"NT",AZ)) Q:'AZ  I $D(^(AZ,0)),'$P(^(0),U,3) S AXMY($TR($P(^(0),U,1,2),"^","@"))=""
	D XMYCHK
	Q
COM	K XMY,AXMY
	F AZ=0:0 S AZ=$O(^A1AE(11007,AN,"PB",AZ)) Q:'AZ  I $D(^(AZ,0)),$P(^(0),U,2)="V" S DOM=$P(^(0),U,3),NAM=$P(^VA(200,AZ,0),U),AXMY(NAM_"@"_DOM)=""
	D XMYCHK
	Q
	;tst ste
TST	K XMY,AXMY
	F AZ=0:0 S AZ=$O(^A1AE(11007,AN,1,AZ)) Q:'AZ  I $D(^(AZ,0)),$L($P(^(0),U,3)) S DOM=$P(^(0),U,3),NAM=$P(^VA(200,AZ,0),U),AXMY(NAM_"@"_DOM)=""
	;
XMYCHK	S AN="" F  S AN=$O(AXMY(AN)) Q:AN=""  I $E(AN,$L(AN))="@" K AXMY(AN)
	MERGE XMY=AXMY
	;should not be necessary with new mailman
	;S (AN,XMN)=0,XMDUZ=DUZ F AZ=0:0 S AN=$O(AXMY(AN)) Q:AN=""  S X=AN D INST^XMA21 I '$D(ZTQUEUED) W "." R ZZ:0
	I '$D(ZTQUEUED) W "." R ZZ:0
	K DOM,NAM,AZ,AN,AXMY,XMN,XMDUZ
	Q
QUE	;ov xminst, 1st mess
	N %
	;S QUE="Q-PATCH.VA.GOV"
	S %=$L(^XMB("NETNAME"),"."),%=$P(^XMB("NETNAME"),".",%-1,%),QUE="Q-PATCH."_%
	S QUE=$O(^XMB(3.7,.5,2,"B",QUE,0)) I 'QUE W !,"No queue 'Q-PATCH'" K QUE Q
	I '$D(^XMB(3.7,.5,2,QUE,0)) W !,"No queue 'Q-PATCH'" K QUE Q
	I QUE<1001 W !,"No queue 'Q-PATCH'" K QUE Q
	S QMES=$O(^XMB(3.7,.5,2,QUE,1,0)) I 'QMES W !,"No messages in Q-PATCH" K QUE,QMES Q
	Q
LOC	;ov a1aerd(),x()=axmz,a1aerd(2)=last
	Q:'$D(QUE)
	S QMESUB=$P(A1AEPD,"*",1,2)
	S QMES=0,AN=0,ADD=^DD("DD")
	F AZ=0:0 S QMES=$O(^XMB(3.7,.5,2,QUE,1,QMES)) Q:'QMES  I $D(^XMB(3.9,QMES,0)),$P(^(0),U)[QMESUB S A0=^(0) D EXTR
	K ADD,A0,AN,AZ,SHOW,QMES Q
EXTR	S AN=AN+1,A1AERD(AN)=AN_U_"Copy message ' "_$P(A0,U)_" '",X(AN)=QMES,A1AERD("B")=AN
	I $D(SHOW) W !,?SHOW,"(",AN,")",?SHOW+5,$E($P(A0,U),1,25),?SHOW+32,$E($S('$P(A0,U,2):$P(A0,U,2),1:$P(^VA(200,$P(A0,U,2),0),U,1)),1,25),?SHOW+59 S Y=$P($P(A0,"^",3),".") X ADD W Y
	Q
	;
FCOPY	;ivAXMZ,A1AEROU,ovRNAM^start^end
	S AROU=A1AEROU
	S BEG="$ROU "_AROU,END="$END ROU "_AROU
	S L1=5+$L(AROU),L2=9+$L(AROU)
	F AZ=0:0 S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)),$E(^(0),1,L1)=BEG!($E(^(0),1,L2)=END) S AP=$E(^(0),1,20) S:AP=BEG RNAM=AROU_"^"_AZ I AP=END,$D(RNAM) S $P(RNAM,"^",3)=AZ Q
	K BEG,END,AROU,AZ,AP,AZ
	Q
	;
44	F XQ=1:1 Q:$P(X,".",XQ,99)=""  I X[$P(X,".",XQ,99) S $P(X,".",1,XQ-1)=XX Q
	Q
