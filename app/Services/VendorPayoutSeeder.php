        // Get existing vendors and users
        $vendors = Vendor::all();
        $users = User::where('role', 'admin')->get(); 