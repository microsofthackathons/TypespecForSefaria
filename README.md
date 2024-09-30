# Typespec For Sefaria
## A Microsoft Global Hackathon 2024 Project

This project is a port of the existing Sefaria API definition to TypeSpec. TypeSpec is a new SDL from the Microsoft Azure Team for writing APIs and generating OpenAPI specs. You can learn more about it [here](https://typespec.io/). It is hoped that this will help Sefaria build out its API ecosystem by making it easier to maintain and extend the API definitions.

This project was created as part of the Microsoft Global Hackathon 2024, but Avi is offering continuing support (some development, communication with TypeSpec engineers, etc.)

# Project Structure

> 🚧 These instructions are rough and subject to change.

Ths project is a a node/npm project. It contains:
- a `original_api` folder with the original OpenAPI definition. This is not quite true, some changes were made to ensure [Spectral](https://marketplace.visualstudio.com/items?itemName=stoplight.spectral) validation, enable import into TypeSpec (such as inlining common parameters), and a handful of others. But the file is essentially the same.
- a `tsp/` folder with the TypeSpec definition. _Use this folder as your workspace root, as it contains packages.json etc._
    - `tspconfig.yaml` config file
    - `main.tsp`, the entry file for openAPI generation
	- a `tag` folder with a file for each tag in the original OpenAPI definition
      - we'll talk about bulktext.tsp later; excluded from main.tsp by default
    - a `model` folder for common models
    - `common.tsp` for models etc used by multiple tags
    - a `tsp-output` folder for the generated OpenAPI definition
      - each emitter (output generator) has its own subfolder. So for the generated OpenAPI definition, you have to drill down to `tsp-output/@typespec/openapi3/openapi.json`.
      - Note that `tsp-output` is excluded from source control via `.gitignore`. This is the default setting for TypeSpec projects, but you can obviously modify .gitignore` to include it if desired.

# Development Setup and Compilation

1. Clone this repo. _For now, we recommend cloning it as an independent directory, but eventually it will be moved inside the [Sefaria-Project](https://github.com/Sefaria/Sefaria-Project) project structure._

2. Navigate into the main working directory, `cd TypespecForSefaria/tsp/`.  

3. Make sure you have node/npm installed. 

4. Install TypeSpec. In theory, `npm i` from `TypespecForSefaria/tsp/` should work. 

5. If `npm i` didn't successfully install TypeSpec, explicitly install it in the same directory by running `npm install -g @typespec/compiler`. Then, install the dependencies by running `tsp install`. 

6. Make sure you have VSCode or Visual Studio installed. If you already have it installed, make sure it is updated.  

7. Install TypeSpec Extension for [Visual Studio](https://marketplace.visualstudio.com/items?itemName=typespec.typespecvs) and/or [VSCode](https://marketplace.visualstudio.com/items?itemName=typespec.typespec-vscode). You can search inside VSCode's extensions sidebar and install it easily there. 

8. Restart your IDE. 

9. Test that TypeSpec was properly installed by attempting to compile using the following two commands: `tsp format **/*.tsp`, `tsp compile .`

10. Confirm that the `tsp/tsp-output/` directory contains a valid `openapi.json` file. 

If it does, great news - you have everything set up properly. 




# Initial Migration
Most of the migration visible in this project was done using TypeSpec's (not-yet-documented) `tsp-openapi3` import command. The workflow essentially looked as follows:
- From the root directory, Execute `npx -p @typespec/openapi3@next tsp-openapi3 ./original_api/openAPI_original.json --output-dir tsp`.
- Compile the generated TypeSpec
- Compare the input and output JSON using [oasdiff](https://www.oasdiff.com/): `oasdiff diff ./original_api/openAPI_original.json tsp/tsp-output/@typespec/openapi3/openapi.json --flatten-params --flatten-allof --format html --exclude-elements examples,title,description > diff.html`. This spits out an HTML file comparing the old and new schemas.
  - If some invalidity of the original API files was causing the correction to crash, it was edited, and the workflow was restarted.
- If non-matching TypeSpec was emitted and it could be fixed by modifying the original API files, that change was made, and the workflow was restarted.
- Once the original OpenAPI spec was valid, descriptions were added to the comparison (they don't play nice with HTML output, so the comparison was done in JSON): `oasdiff diff ./original_api/openAPI_original.json tsp/tsp-output/@typespec/openapi3/openapi.json --flatten-params --flatten-allof --format json --exclude-elements examples,title > diff.json`
- The original generated TypeSpec file was refactored into several files (`common.tsp`, `model` folder, `tag` folder).
- All remaining changes were triaged and, if necessary, fixed by hand. Bugs discovered in the import command were filed with the TypeSpec team.

# BilingualOf\<T\>
Most of the code is straight ports of the source OpenAPI, just transpiled and split into multiple files. I would say to read these three documentation sections, and "the rest is commentary".

- [Guide - TypeSpec for REST](https://typespec.io/docs/next/getting-started/getting-started-rest/01-setup-basic-syntax)
- [Language Basics](https://typespec.io/docs/next/language-basics/overview)
- [Guide - TypeSpec for the OpenAPI developer](https://typespec.io/docs/next/getting-started/typespec-for-openapi-dev)


I made one change, though, as a simple example of what TypeSpec can do.

In `common.tsp`, you'll notice the `BilingualOf<T>` alias and `BilingualOfWithDocumentation<T, heDoc, enDoc>` model. These are used to replace all intances of `en` and `he` being two properties (often the only properties) of an object.

The alias version is essentially just a macro, and doesn't support setting comments. It's used when possible to minimize the changes to the output OpenAPI in this stage of the port.

The model version actually creates a model schema in the generated OpenAPI that matches the definition (including documentation). To minimize the changes to the OpenAPI output, the object is `...`- spread into the response objects instead of targeted directly.

Together, these replace all references to the old `BilingualJSON` object.

# Bulk Text API
The `bulktext.tsp` file is not part of the port (which is why its import statement is commented out in `main.tsp`.) It served as the example demonstrated at the Hackathon "science fair" of how easy it is to write a new endpoint in TypeSpec. (It took about an hour to write, _including_ the time it took to read Sefaria's source code and make test calls to the endpoint.)

While it doesn't follow the full TypeSpec-recommended conventions as visible in the Guide (e.g. using interfaces to group operations on the same model type), it is a bit more aggressive in using type features (unions, `extends`) than the existing code.

# Gaps/Todo
- The schema `title`s were not imported from the original TypeSpec. It was decided that these were not needed for manual migration.
- The `uniqueItems` property is not yet supported in TypeSpec. It was decided this is non-critical.
- Examples have not been imported yet.
  - Support for model and response examples exists in TypeSpec; the work has to be done.
  - Parameter examples are not supported, but a workaround exists (which I will add once regular models have been imported/migrated.)
