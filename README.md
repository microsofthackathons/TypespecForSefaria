# Typespec For Sefaria
_TypeSpec definitions for Sefaria. (Global Hackathon 2024)_

[Sefaria](https://www.sefaria.org/) is the world's largest open-source database of Jewish texts, and its user-facing portal is used by thousands daily. (A brief introduction can be found in this [two-minute video](https://youtu.be/XRPHRo0bb2o)).

They are trying to build a developer ecosystem around [the API](https://developers.sefaria.org/reference/getting-started-with-your-api) used by their web portal, but they're getting held back by maintenance of their [OpenAPI spec](https://github.com/Sefaria/Sefaria-Project/blob/master/docs/openAPI.json). We would like to catalyze their work with [TypeSpec](https://typespec.io/), a domain-specific language created by the Microsoft Azure API team that makes it easy to define OpenAPI specs using TypeScript- and C#-like syntax:

- Migrate the existing OpenAPI definition to TypeSpec
- Add missing OpenAPI calls using TypeSpec
- Use TypeSpec- or OpenAPI-generated clients to have Sefaria's portal dogfood its own APIs

[HackBox (for employees)](https://hackbox.microsoft.com/hackathons/hackathon2024/project/60906)
