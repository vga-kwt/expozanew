import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";

const DashboardStatCard = () => {
    return (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{"title"}</CardTitle>
                {/* <Icon className="text-muted-foreground h-4 w-4" /> */}
            </CardHeader>
            <CardContent>
                <div className="text-2xl font-bold">{"value"}</div>
                <p className="text-muted-foreground text-xs">{"description"}</p>
            </CardContent>
        </Card>
    );
};

export default DashboardStatCard;
