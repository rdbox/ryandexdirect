yadirGetSiteLinks <- function(Login = NULL,
                              Token = NULL,
                              AgencyAccount = NULL,
                              TokenPath     = getwd()) {
  
  # �������������� �����
  result <- data.frame()
  
  #�����������
  Token <- tech_auth(login = Login, token = Token, AgencyAccount = AgencyAccount, TokenPath = TokenPath)
  
  # ��������� �������� � ����� �� �-�� �����
  offset <- 0
  limit  <- 10000
  
  dataRaw <- list()
  # ��������� ���� 
  while (! is.null(dataRaw$result$LimitedBy) || offset == 0 ) {
    # ��������� ���� �������
    queryBody <- paste0("{
      \"method\": \"get\",
                          \"params\": {
                              \"FieldNames\": [\"Id\", \"Sitelinks\"],
                              \"Page\": {  
                                \"Limit\": ",limit,",
                                \"Offset\": ",offset,"}
        }
      }")
    
    # ���������� ������ � API
    answer <- POST("https://api.direct.yandex.com/json/v5/sitelinks", body = queryBody, add_headers(Authorization = paste0("Bearer ",Token), 'Accept-Language' = "ru",'Client-Login' = Login))
    stop_for_status(answer)
    
    # ������ �����
    dataRaw <- content(answer, "parsed", "application/json")
    
    # �������� �� ������
    if(length(dataRaw$error) > 0){
      stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
    }
    
    # ������ ���������� ���������
    for (i in seq_along(1:length(dataRaw$result$SitelinksSets))) {
      for (y in seq_along(1:length(dataRaw$result$SitelinksSets[[i]]$Sitelinks)))
        result <- rbind(result, 
                        data.frame(Id          = dataRaw$result$SitelinksSets[[i]]$Id,
                                   Title       = ifelse(is.null(dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Title), NA, dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Title),
                                   Href        = ifelse(is.null(dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Href), NA, dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Href),
                                   Description = ifelse(is.null(dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Description), NA, dataRaw$result$SitelinksSets[[i]]$Sitelinks[[y]]$Description))
                                    )
    }
    
    # �������� ��������� �� ��������� ���
    if (! is.null(dataRaw$result$LimitedBy)) {
      offset <- offset + limit
    } else {
      break
      }
  }
  
  # ���������� ���������� ������
  return(result)
}
