
//import std.stdio;
import vibe.d;

shared static this()
{
	auto router = new URLRouter;
	router.get("/", &showHome);
	router.get("/about", staticTemplate!"about.dt");
	router.get("*", serveStaticFiles("public"));

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.errorPageHandler = toDelegate(&showError);
	settings.bindAddresses = ["::1", "127.0.0.1"];

	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

void showError(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	res.render!("error.dt", req, error);
}

void showHome(HTTPServerRequest req, HTTPServerResponse res)
{
	string username = "ethereum Test";
	res.render!("home.dt", req, username);
}




