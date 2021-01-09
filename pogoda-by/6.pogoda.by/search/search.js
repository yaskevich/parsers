var
	SearchEngine = null;
	
(function()
{
	if (SearchEngine == null)
	{
		SearchEngine = new Object();
	}
	SearchEngine.Execute = function(request)
	{
		var
			channel = null;
		
		if (request != '')
		{
			try
			{	
				channel = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e)
			{
				try
				{
					channel = new XMLHttpRequest();
				}
				catch (e)
				{
					channel = null;
				}
			}
			//---------------------------------------------------------------------
			//Названия городов
			if (request_Lower = request.toLowerCase()) {
				if (request_Lower == 'санкт-петербург' || request_Lower == 'спб' || request_Lower == 'петербург') {
					request = 'ст.петербург';
				}
				if (request_Lower == 'нижний новгород') {
					request = 'н.новгород';
				}
				if (request_Lower == 'марьина горка') {
					request = 'м.горка';
				}
				if (request_Lower == 'великие луки') {
					request_Lower = 'в.луки';
				}
			}
			//---------------------------------------------------------------------
			if (channel != null)
			{
				//channel.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=utf-8');
				channel.onreadystatechange = function()
				{ 
					if(channel.readyState == 4)
					{
						if(channel.status == 200)
						{
							var
								response = eval('(' + channel.responseText + ')');
							
							if (response["status"] == "url")
							{
								window.location = response["content"];
							}
							if (response["status"] == "txt")
							{
								document.getElementById('result').innerHTML = response["content"];	
							}
						}
						else
						{
							document.getElementById('result').innerHTML = 'Произошла ошибка. Попробуйте позже.';
						}
					}
				}
				if (channel.open("GET", "/search/process.php?request=" + encodeURIComponent(request), true) || true)
				{
					channel.send(null);
				}
			}
			else
			{
				window.location = 'http://6.pogoda.by/search/?request=' + encodeURIComponent(request);
			}
		}
	}
})();