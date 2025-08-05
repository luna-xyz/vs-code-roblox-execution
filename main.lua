repeat task.wait() until game:IsLoaded();

if getgenv().vs_code_ws then

	if vs_code_extension.DebugMode then warn("[ WEB_SOCKET ]: Web socket already connected."); end;
	return;
end;

getgenv().vs_code_extension = getgenv().vs_code_extension or {

	AutoReconnect = true;
	DebugMode = false;
};

if vs_code_extension.DebugMode then warn("[ WEB_SOCKET ]: Connecting Web socket.."); end;

local connect_ws = function()

	getgenv().vs_code_ws = WebSocket.connect("ws://localhost:33882/");
	vs_code_ws:Send("auth:" .. tostring(game:GetService("Players").LocalPlayer.UserId));

	vs_code_ws.OnMessage:Connect(function(__m)

		local __s, __d = pcall(function()
			return loadstring(__m)();
		end);

		if not __s then vs_code_ws:Send("compile_err:" .. tostring(__d)); return; end;
	end);

	vs_code_ws.OnClose:Connect(function()

		if not vs_code_extension.AutoReconnect then return; end;
		if vs_code_extension.DebugMode then warn("[ WEB_SOCKET ]: Web socket closed."); warn("[ WEB_SOCKET ]: Reconnecting web socket.."); end;
		
		connect_ws();
	end);

    if not vs_code_extension.AutoReconnect then queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/luna-xyz/vs-code-roblox-execution/refs/heads/main/main.lua'))();"); end;
	if vs_code_extension.DebugMode then warn("[ WEB_SOCKET ]: Web socket connected."); end;
end;

local __s, __d = pcall(function()
	connect_ws();
end);

if vs_code_extension.DebugMode and not __s then

	coroutine.resume(coroutine.create(function()

		while task.wait(3) and not vs_code_ws and vs_code_extension.AutoReconnect do

			local __s, __d = pcall(function()
				connect_ws();
			end);
			
			if vs_code_extension.DebugMode and not __s then warn("[ WEB_SOCKET ]: " .. tostring(__d)); end;
		end;
	end));
	
	warn("[ WEB_SOCKET ]: " .. tostring(__d));
end;
