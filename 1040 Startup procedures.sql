SELECT [name]
  FROM sysobjects
 WHERE type                                = 'P'
   AND OBJECTPROPERTY(id, 'ExecIsStartUp') = 1;