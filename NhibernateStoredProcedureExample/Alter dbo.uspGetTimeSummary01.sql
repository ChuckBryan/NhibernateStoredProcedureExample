USE [Timetracker]
GO

/****** Object: SqlProcedure [dbo].[uspGetTimeSummary01] Script Date: 6/9/2023 11:54:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
EXEC uspGetTimeSummary01 55,Null,3,'12/31/2011',0,2
EXEC uspGetTimeSummary01 null,Null,1,'11/1/2011',0,null

EXEC uspGetTimeSummary01 55,Null,Null,'2/4/2012',0,null

EXEC uspGetTimeSummary01 55, NULL, 1, '11/10/2012', 1, null

*/
ALTER PROC [dbo].[uspGetTimeSummary01]
		(
		 @UserID			int
		,@ProjectID			int
		,@BillCycleID		int
		,@PeriodEnding		smalldatetime
		,@IncludeNonBill	bit = 0
		,@InvoiceTypeID		int
		)

AS

SET NOCOUNT ON
---
-- Declarations and Initialization
---
Declare	@Debug		bit
Declare	@SQL		nvarchar(4000)
Declare	@Fieldlist	nvarchar(1000)
Declare @Join		nvarchar(1000)
Declare	@Where		nvarchar(1000)
Declare	@OrderBy	nvarchar(1000)
Declare	@GroupBy	nvarchar(1000)
Declare @IsPM		bit
Declare @HardCopy	INT; SET @HardCopy = 3
SET	@Debug = 0

SELECT	 @IsPm = Count(*)
FROM	TT_Users a
		INNER JOIN aspnet_Users b on a.UserName = b.UserName
		INNER JOIN aspnet_UsersInRoles c on b.UserId = c.UserId
WHERE	a.UserID = @UserID
		and c.RoleId = 'A0D4C8A0-523F-49A9-8106-72A18EE03B54'

SET @Join = 
CASE  WHEN @IsPM = 0 THEN  '' Else
	 '	INNER JOIN TT_ProjectManagerProjects b on a.ProjectID = b.ProjectID and b.userId = ' +  Cast(@UserID AS nvarchar(8)) +'
	 '
end


----
--***Build SQL***
----

--Fields
SET @Fieldlist =
'
	a.ClientId
	-- ,a.UserID as UserID1_0_
	,a.DisplayName 
	-- ,a.ProjectID ProjectID1_0_
	,a.Name
	,Case When a.BillCycleID=1 Then a.WeekEnding Else a.MonthEnding End	^PeriodEnding^
	,a.BillCycle
	,a.InvoiceType
	,Sum(a.Duration)											^PeriodHours^
	,Sum(Case When a.Billable=1 Then a.Duration Else 0 End)		^BillableHours^
	,Sum(Case When a.Billable=0 Then a.Duration Else 0 End)		^NonBillableHours^
'

--Where Clause
SET @Where =
'WHERE
	1=1
'
--+
--Case When @UserID Is Null Then '' Else
--' AND a.UserID=' + Cast(@UserID AS nvarchar(8))
--End
+
Case When @ProjectID Is Null Then '' Else
' AND a.ProjectID=' + Cast(@ProjectID AS nvarchar(8))
End
+
Case 
When @BillCycleID =1 Then 
' AND (a.BillCycleID = 1 AND a.WeekEnding = ^' + Convert(varchar(12),@PeriodEnding,101) + '^)'
When @BillCycleID = 3 Then
' AND (a.BillCycleID = 3 AND a.MonthEnding = ^' + Convert(varchar(12),@PeriodEnding,101) + '^)'
End
+
Case When @InvoiceTypeID Is Null Then '' 
Else CASE WHEN @InvoiceTypeID = 2 THEN -- If it is a SOFT copy also include portal
' AND (a.InvoiceTypeID=' + Cast(@InvoiceTypeID AS nvarchar(8)) +   'OR a.InvoiceTypeID=5 OR a.InvoiceTypeID=' + CAST(@HardCopy as nvarchar(8)) + ') '
ELSE 
' AND (a.InvoiceTypeID=' + Cast(@InvoiceTypeID AS nvarchar(8)) + ' OR a.InvoiceTypeID=' + CAST(@HardCopy as nvarchar(8)) + ') '
End END
+
Case When @IncludeNonBill = 1 THEN '' ELSE
' AND a.Billable=1'
END
--Group By
SET @GroupBy = 
'
	 a.UserID
	,a.ClientID
	,a.DisplayName
	,a.ProjectID
	,a.Name
	,Case When a.BillCycleID=1 Then a.WeekEnding Else a.MonthEnding End
	,a.BillCycle
	,a.InvoiceType
'

--Order By
SET @OrderBy =
'
	a.ClientId
	, a.ProjectID
	 ,a.DisplayName
'

--***Put it All Together***
SET @SQL =
'SELECT 
'
+
@Fieldlist
+
' FROM
	vwTimeDetail a
'
+
@Join
+
@Where
+
Case When @GroupBy <> '' Then 
'
GROUP BY
' Else '' End
+
@GroupBy
+
Case When @OrderBy <> '' Then 
'
ORDER BY
' Else '' End
+
@OrderBy

SET	@SQL = Replace(@SQL,'^',CHAR(39))

If @Debug=1
	Begin
	PRINT @SQL
	GOTO EXIT_SP
	End
	
---
--Output Data
---
EXEC (@SQL)

---
EXIT_SP:
---
SET NOCOUNT OFF
