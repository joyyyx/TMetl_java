package com.example.taimeietl.tools.httpClient.requests;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.*;

public interface WebServices {
    @Headers({
            "Content-Type: text/xml"
    })
    @POST
    Call<String> getSoapRepose(@Url String url, @Body String requestBody);

    @GET
    Call<String> getGetRepose(@Url String url);

    @GET
    Call<ResponseBody> downloadFile(@Url String fileUrl);
}
