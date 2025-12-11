// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";

//import SalesController from "./sales_controller";
//application.register("sales", SalesController);

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);
