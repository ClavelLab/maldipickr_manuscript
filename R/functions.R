check_data_directory<-function(){
  if(!dir.exists(here::here("data"))){
    dir.create(
      here::here("data")
    )
  }
}