using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Raceway.Models.ViewModels;
using Microsoft.AspNetCore.Authorization;

namespace Raceway.Controllers
{
    [Authorize(Roles = "Admin")]
    public class UserRoles : Controller
    {
        private readonly UserManager<IdentityUser> userManager;
        private readonly RoleManager<IdentityRole> roleManager; 

        public UserRoles(
            UserManager<IdentityUser> UserManager,
            RoleManager<IdentityRole> roleManager


            )
        {
            userManager = UserManager;
            roleManager = roleManager;
        }
           
        //Get: /UserRoles
        public async Task<IActionResult> Index()
        {
            var users = await userManager.Users.ToListAsync();
            var UserRolesViewModel = new List<UserRolesViewModel>();

            foreach( var user in users)
            {
                var thisViewModel = new UserRolesViewModel
                {
                    UserId = user.Id,
                    Email = user.Email ?? "",
                    UserName = user.UserName ?? "",
                    Roles = await userManager.GetRolesAsync(user)
                };

                UserRolesViewModel.Add(thisViewModel);
            }
            return View(UserRolesViewModel);
        }


        //Get: / UserRoles/Manager?UserId=xxx
        public async Task<IActionResult> Manage (String UserId)
        {

            ViewBag.UserId = UserId;

            var user = await userManager.FindByIdAsync(UserId);

            if (user == null)
            {
                ViewBag.ErrorMessage = $"User with Id ={UserId} cannot be found!!";
                return View("Not Found");
            }

            ViewBag.UserName = user.UserName;

            var model = new List<ManageUserRolesViewModel>();

            foreach(var role in roleManager.Roles.ToList())
            {
                var userRolesViewModel = new ManageUserRolesViewModel
                {
                    RoleId = role.Id,
                    RoleName = role.Name ?? ""
                };

                if(await userManager.IsInRoleAsync(user, role.Name!))
                {
                    userRolesViewModel.isSelected = true;

                }
                else
                {
                    userRolesViewModel.isSelected= false;
                }

                model.Add(userRolesViewModel);
            }
            return View(model);
        }

        //Post: /UserRoles/Manage 
        [HttpPost]
        [ValidateAntiForgeryToken]

        public async Task<IActionResult> Manage (List<ManageUserRolesViewModel> model, string userId)
        {
            var user = await userManager.FindByIdAsync(userId);
            if(user == null)
            {
                return View("NotFound");
            }

            var roles = await userManager.GetRolesAsync(user);
            var result = await userManager.RemoveFromRolesAsync(user, roles);

            if (!result.Succeeded)
            {
                ModelState.AddModelError("", "Cannot remove user existing role!");
                return View(model);
            }

            result = await userManager.AddToRoleAsync(user, model.Where(x => x.isSelected).Select(y => y.RoleName));

            if (!result.Succeeded)
            {
                ModelState.AddModelError("", "Cannot add selected roles to user!");
                return View(model);
            }

            return RedirectToAction(nameof(Index));
        }

    }
}
