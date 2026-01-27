import { Application } from "@hotwired/stimulus"
import HelloController from "./hello_controller"
import TailwindTestController from "./tailwind_test_controller"
import FullscreenController from "./fullscreen_controller"
import SidebarController from "./sidebar_controller"
import DropdownController from "./dropdown_controller"
import TabsController from "./tabs_controller"
import ProfileFormController from "./profile_form_controller"

window.Stimulus = Application.start()
Stimulus.register("hello", HelloController)
Stimulus.register("tailwind-test", TailwindTestController)
Stimulus.register("fullscreen", FullscreenController)
Stimulus.register("sidebar", SidebarController)
Stimulus.register("dropdown", DropdownController)
Stimulus.register("tabs", TabsController)
Stimulus.register("profile-form", ProfileFormController)
